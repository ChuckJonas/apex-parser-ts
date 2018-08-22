'use strict';

import {ExtractSymbols} from '../extractSymbols'

import * as fs from 'fs';

import * as os from 'os';
class Startup {
    public static main(): number {
        let symbolExtractor = new ExtractSymbols();
        symbolExtractor.findSymbolsFromFile('./src/testing/Demo.cls').then((symbolListener)=>{
            symbolListener.symbolTable.symbols.forEach(sym => {
                console.log(`${sym.name}
                Symbol Type: ${sym.symbolType}
                Start Line:${sym.source.start.line}
                Start Column:${sym.source.start.charPositionInLine}
                Stop Line:${sym.source.stop.line}
                Stop Column:${sym.source.stop.charPositionInLine}
                Type:${sym.type}
                Attributes:${JSON.stringify(sym.attributes)}`);
            });
        });

        return 0;
    }

}


Startup.main();






