# Programs
An API for opening, registering, executing, and managing programs with MTMOS's program manager.
Programs registered with the program manager are fully customizable outside of the specified requirements.

### Index


- [Specifications](#####Specifications) - The specifications that a program for MTMOS must adhere to.
#### API methods
- [Programs.make](#####Programs.make) - Take a table and register it as a program. (See: [Specifications](#####Specifications))
- [Programs.open](#####open) - Load a lua file and run it through [make](#####Programs.make) to register it as a program. (See: [Specifications](#####Specifications))
- [Programs.setFocusedProgram](#####Programs.setFocusedProgram) Sets the program that's being rendered to the screen. *Please* see details for usage.
#### Program object methods and members
- `Program.container` : `table` - The container for the program used by the program manager.
- `Program.container.eq` : `Queue` - The event [queue](#) for events dispatched to the program
- `Program.container.module` : `table` - The table returned by the program when initially loaded and called; Same as `Program`. Exists so that the container and program itself may reference each other.
- `Program.container.suspended` : `boolean` - Whether the program should tick
- `Program.container.uuid`: `UUID` - The [UUID](#) of the program
- `Program.container.monitor`: `nil` | `term` - The screen that should be rendered to by the program.
- `Program.container.name` : `string` - The name of the program.
- `Program.container.name_pretty` : `nil` | `string` - The pretty name of the program
- `Program.container.main_thread` : `thread` - The thread used by the program manager to tick the program.
- `Program.container.draw_thread` : `nil` | `thread` - The thread used by the program manager to render to `Program.container.monitor` if `Program.Draw` is not `nil`.
- `Program.container.window` : `nil` | `window` - The [window](https://tweaked.cc/module/window.html) to render to if `Program.Draw` is not `nil`.
- `Program.container.tickFunc` : `function` - The function used by the program manager to resume the program's `Main` function.
- `Program.container.drawFunc` : `function` - The function used by the program manager to resume the program's `Draw` function if `Program.Draw` is not `nil`.


### Specifications
The requirements for a program that is compatible with MTMOS's Program Manager.

### Methods
These are the methods available in the `Programs` API.

##### Programs.make
Take a table and register it as a program. Table must have a `Main` function and an `Info` function.

`Programs.make(module)`
- `module` : `table` - The table returned by the program when initially loaded and called.

`return` : `Program` - The constructed program

##### Programs.open
Load a lua file and run it through [Programs.make](#####Programs.make) to register it as a program.

`Programs.open(path)`
- `path` : `string` - The path of the file to load and register as a program.

`returns` : `Program` - The constructed program

##### Programs.setFocusedProgram
Set which program the Program Manager calls [Draw](#####Draw) on.

`Programs.setFocusedProgram(program)`
