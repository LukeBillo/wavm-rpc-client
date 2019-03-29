# JavaScript API Design

This document discusses the API design for using WebAssembly from JS when it is hosted in a virtual machine.

---
## Initialisation

The very first function to be called will need to initialise the virtual machine with a `.wasm` module.

```ts
WAVM.Initialise(module: string): Promise<bool>
```

This function will call the Haskell RPC endpoint and tell it to run initialise WAVM with a the module specified. On completion, it will either successfully instantiate WAVM and return `true` or fail (in the case that either the module did not exist, invalid, etc.) and return `false`.

**Future Work**: It may be possible to return a `Promise<Module>` where `Module` contains a JS representation of the WebAssembly functions that were loaded.

---
## Calling a Function

```ts
WAVM.Execute(function: string, ...args: any[]): Promise<any>
```

Calling `Execute` will execute the function (provided by name), passing the given array of arguments.

---
## Handling Asynchronous Calls

Calls from JavaScript can be something like the following:
```js
function callWavmFunctions() {
    const mySyncResult = execute("mySyncFunction");
    const asyncResult = execute("myAsyncFunction");

    Promise.resolve(asyncResult).then(...);
}
```

If the RPC server were to do these in order on the same socket in a REQ-REP format, if `mySyncFunction` took a long time then it would end up like this:

1. `mySyncFunction` request received
2. Execute `mySyncFunction` and returns value
3. `myAsyncFunction` request received
4. Execute `myAsyncFunction` and returns value
5. Now able to resolve `Promise.resolve(asyncResult)`

This is not ideal, as the async function would need to wait for the sync function to complete. This would still be the same case with running two async functions, as the bottleneck would be the REQ-REP socket itself.21