'use strict';

import {ANTLRInputStream, CommonTokenStream} from 'antlr4ts';
import {TerminalNode, ParseTreeWalker}  from 'antlr4ts/tree';
import {ApexcodeLexer} from './grammar/ApexcodeLexer'
import {ApexcodeParser} from './grammar/ApexcodeParser'
import {SymbolReader, SymbolTable} from './symbolReader'

import * as fs from 'fs';
import * as os from 'os';

export class ExtractSymbols{

    public findSymbolsFromFile(file: string): Promise<SymbolReader>{
        return new Promise<SymbolReader>((resolve, reject) => {
                fs.readFile(file, (err, data) =>{
                    if(!err){
                        resolve(this.findSymbolsFromString(data.toString()));
                    }else{
                        console.log(err);
                        reject(err);
                    }
                });
            }
        );
    }

    public findSymbolsFromString(data: string): SymbolReader{
        let inputStream = new ANTLRInputStream(data);
        let lexer = new ApexcodeLexer(inputStream);
        let tokenStream = new CommonTokenStream(lexer);
        let parser = new ApexcodeParser(tokenStream);
        parser.buildParseTree = true;
        var tree = parser.compilationUnit();
        let symbolListener = new SymbolReader(parser);
        ParseTreeWalker.DEFAULT.walk(symbolListener, tree);
        return symbolListener;
    }

}