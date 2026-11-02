# Patrones técnicos en WPF

Reglas y soluciones recurrentes que aplican a **cualquier proyecto WPF** de la empresa.
No contienen lógica de dominio.

---

## Abrir modales desde doble click en DataGrid

**Causa más habitual de "el modal se reabre al cancelar": doble suscripción
al doble click.** Un `MouseBinding Gesture="LeftDoubleClick"` en XAML *y además*
un `MainDataGrid.MouseDoubleClick += handler` en code-behind que ejecutan el
mismo command. El primero abre el modal; el segundo queda en cola y lo reabre
al cerrarse el primero.

**Solución correcta**: elegir UNA de las dos vías y marcar `e.Handled = true`
en el handler:

```csharp
// En el code-behind del listado:
MainDataGrid.MouseDoubleClick += (_, e) =>
{
    if (_viewModel?.ModificarCommand.CanExecute(null) == true)
    {
        _viewModel.ModificarCommand.Execute(null);
        e.Handled = true;
    }
};
```

Y en el XAML del DataGrid, **NO** añadir `InputBindings` con `LeftDoubleClick`
si ya se maneja en code-behind.

Al crear un nuevo listado, **buscar ambas referencias antes de considerarlo
cerrado**:

```
grep -c "LeftDoubleClick" *.xaml
grep -c "MouseDoubleClick" *.xaml.cs
```

Si hay `>= 1` en los dos, hay bug.

**Mitigación secundaria** (solo si quieres blindaje extra): encapsular la
apertura en un helper `ModalLauncher.AbrirDiferido(Action)` que usa
`Dispatcher.BeginInvoke(DispatcherPriority.Background, ...)`. Así, incluso si
alguien vuelve a introducir una doble suscripción por error, el modal no
reaparece tan inmediatamente. No es la solución — es una red. La solución
real es la suscripción única con `e.Handled`.

---

## Selección de celdas estilo Excel en `DataGrid`

Para que el usuario pueda seleccionar rango de celdas con el ratón (arrastre,
Shift/Ctrl) y copiar al portapapeles con Ctrl+C pegando en Excel:

```xml
SelectionMode="Extended"
SelectionUnit="CellOrRowHeader"
ClipboardCopyMode="IncludeHeader"
```

**Detalle importante**: el modo nativo de copiado falla con celdas que bindean a
`Dictionary[clave]` (columnas dinámicas). En ese caso interceptar
`ApplicationCommands.Copy` en code-behind, leer los valores por reflexión sobre
el `Binding.Path` y poner en el portapapeles **tres formatos**: `UnicodeText`
(TSV), `Text` (CSV) y `Html` con cabecera `CF_HTML` bien construida.

---

## Preservar colores de la celda al seleccionarla

El estilo por defecto del `DataGridCell` pinta un background de selección que
**tapa** colores aplicados por converters (semáforo, zebra…).

**Solución:** redefinir `CellStyle` con una `ControlTemplate` propia que
consuma el `Background` vía `TemplatedParent` y, en el trigger `IsSelected=True`,
**solo cambie el grosor del borde** (no el fondo). Así el semáforo y la zebra se
conservan y el usuario ve un marco estilo Excel alrededor de la selección.

---

## Columnas dinámicas bindeadas a `Dictionary`

Para bindear una celda a un valor por clave dentro de un diccionario del modelo:

```csharp
new DataGridTextColumn
{
    Binding = new Binding($"PromediosCalidad[{codigoCampo}]")
    {
        StringFormat = "N2",
        TargetNullValue = string.Empty
    }
}
```

**Importante**: si esa "columna" es en realidad una propiedad calculada (no
existe como entrada del diccionario), añadirla como propiedad calculada al
modelo. De lo contrario el binding falla silenciosamente y la columna aparece
vacía. Ver como ejemplo `FilaResumenMedias.ProduccionMediaHaEntregada` en SIA.

---

## Filas alternas (zebra)

```xml
AlternationCount="2"
AlternatingRowBackground="{StaticResource FilaAlterna}"
```

Color de fila alterna sugerido: `#F6F8FA` (gris muy suave, legible con texto
oscuro y con texto azul corporativo).

---

## Configurador de columnas visibles con persistencia

Cada vista seria de listado debería permitir elegir qué columnas ve el usuario
(checkboxes en un popup) y persistir la elección entre sesiones. Plantilla:

- `Modelos/ColumnConfig.cs` (`ColumnName`, `DisplayName`, `IsVisible`,
  `IsRequired`, `Width`, `DisplayIndex`).
- `Servicios/ColumnConfigService.cs` que serializa a JSON en
  `%APPDATA%/<Proyecto>/ColumnConfigs/<Vista>.json`.
- `BaseVistaModelo.ColumnConfigs` (ObservableCollection) heredado por los VMs.
- Popup con `ItemsControl` sobre `ColumnConfigs` + botón "Restaurar todas".
- Binding de `Visibility` de cada `DataGridColumn` al `ColumnConfig`
  correspondiente mediante `ColumnVisibilityConverter`.

---

## Export a Excel con ClosedXML

NuGet: `ClosedXML`. Genera `.xlsx` real con formato (colores, anchos, freeze,
formato condicional). Preferible a CSV cuando se quiere preservar estilo.

Patrón recomendado: un `IServicioExportacionExcel` centralizado que reciba la
colección + `ColumnaExportacion<T>` (cabecera, extractor de valor, formato
numérico, alineación, opcional `ObtenerEstadoSemaforo`) + opcional fila TOTAL.
Permite reutilizar desde cualquier VM. Ejemplo:
`SIA/Presentacion.Wpf/Servicios/ServicioExportacionExcel.cs`.

---

## Eliminación diferida en formularios con botón Guardar general

Si un formulario modal tiene **"Guardar / Cancelar"** a nivel ventana, los
botones "Eliminar" de sub-grids **no deben** tocar BD en el acto. Patrón:

- El VM mantiene listas `_clausulasAEliminar`, `_camposAEliminar`, etc.
- El botón "Eliminar" del grid quita del UI y añade el Id a la lista.
- El botón **Guardar** purga las listas en BD al final.
- El botón **Cancelar** descarta las listas → BD intacta.

Coherente con la expectativa del usuario de que "Cancelar deshace todo".
Ejemplo: `SIA/Presentacion.Wpf/ViewModels/ContratoFormViewModel.cs`.

---

## Ventanas modales con cabecera personalizada (`WindowStyle=None`)

Los botones de maximizar/cerrar deben quedar **pegados al borde superior
derecho** sin padding ni margen intermedio:

- No poner `Padding` en el Border que envuelve la cabecera.
- Poner el margen en el contenido interno (título, datos), no en el contenedor
  exterior.
- Botones con `VerticalAlignment="Top"` y `HorizontalAlignment="Right"`.
- La cabecera debe soportar `DragMove()` en `MouseLeftButtonDown`.

---

## `VisualTreeHelper.GetParent` y texto con `Run`s

**Problema:** `VisualTreeHelper.GetParent(x)` lanza
`InvalidOperationException: 'System.Windows.Documents.Run' no es un Visual ni
un Visual3D` cuando `x` es un `FrameworkContentElement` (p. ej. un `Run` dentro
de un `TextBlock` estructurado, o un `Hyperlink`). Se reproduce típicamente al
hacer doble click en un `DataGrid` donde la celda tiene `TextBlock` con varios
`Run`s — `e.OriginalSource` es el `Run` concreto que se pulsó.

**Solución:** subir por el árbol **visual** solo si el nodo es `Visual`/`Visual3D`;
si no, subir por el árbol **lógico** hasta reengancharlo al visual.

```csharp
public static T? FindParent<T>(DependencyObject? child) where T : DependencyObject
{
    while (child != null)
    {
        if (child is Visual || child is Visual3D)
            child = VisualTreeHelper.GetParent(child);
        else
            child = LogicalTreeHelper.GetParent(child);
        if (child is T match) return match;
    }
    return null;
}
```

**Patrón recomendado:** centralizar en un `TreeHelpers.FindParent<T>` en el
proyecto y evitar reescribir `FindVisualParent` local en cada vista (es un bug
que se replica por copy-paste). Ejemplo de referencia:
`SIA/Presentacion.Wpf/Comandos/TreeHelpers.cs`.
