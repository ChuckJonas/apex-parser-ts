
import {ClassDeclarationContext,
        MethodParametersContext,
        ClassConstructorContext,
        ClassMethodContext,
        ClassPropertyContext} from './grammar/ApexcodeParser';

import {TerminalNode} from 'antlr4ts/tree';

import {Token} from 'antlr4ts/Token';
import {TokenStream} from 'antlr4ts/TokenStream';
import {ApexcodeParser} from './grammar/ApexcodeParser';
import {ApexcodeListener} from './grammar/ApexcodeListener';

export class Position{
    public line: number;
    public column: number;
    constructor(line: number, column: number){
        this.line = line;
        this.column = column;
    }
}

export class Source{
    public start : Token;
    public stop : Token;
    public text : String;

    constructor(start: Token, stop: Token){
        this.start = start;
        this.stop = stop;
    }
}

export class Symbol{
    public name: String;
    public type: String;
    public attributes: any;
    public source: Source;
    public symbolType: string;

    constructor(source: Source, name: String, type: string, attributes: Object){
        this.source = source;
        this.name = name;
        this.type = type;
        this.attributes = attributes;
    }
}

export class SymbolTable{

    public parentTable: SymbolTable;
    public symbols: Map<String, Symbol>;

    constructor(parentTable: SymbolTable){
        this.parentTable = parentTable;
        this.symbols = new Map<String,Symbol>();
    }

    public insert(symbol: Symbol){
        this.symbols.set(symbol.source.text, symbol);
    }
}

export class SymbolReader implements ApexcodeListener {
    //the name of the current file we are reading
    public class: String;
    public symbolTable : SymbolTable;

    private parser : ApexcodeParser;
    constructor(parser: ApexcodeParser){
        this.parser = parser;
        this.symbolTable = new SymbolTable(null);
    }

    public enterClassDeclaration(ctx: ClassDeclarationContext){
        let tokens = this.parser.inputStream;

        let source = new Source(ctx.start, ctx.stop);
        source.text = tokens.getText(ctx);

        let className = ctx.className().text;
        //set class if top level
        if(!this.class){
            this.class = className;
        }
        let sym = new Symbol(source, className, className, null);
        sym.symbolType = 'class';
        this.symbolTable.insert(sym);
    }

    public enterClassConstructor(ctx: ClassConstructorContext){
        let tokens = this.parser.inputStream;

        let source = new Source(ctx.start, ctx.stop);
        source.text = tokens.getText(ctx);

        let id = ctx.qualifiedName().text

        let params = this.generateParametersObject(ctx.methodParameters());
        let sym = new Symbol(source, id, id, {params: params});
        sym.symbolType = 'constructor';
        this.symbolTable.insert(sym);
    }

    public enterClassProperty(ctx: ClassPropertyContext){
        let tokens = this.parser.inputStream;

        let source = new Source(ctx.start, ctx.stop);
        source.text = tokens.getText(ctx);

        let type = "void";
        if ( ctx.dataType()!=null ) {
            type = tokens.getText(ctx.dataType());
        }
        let id = ctx.propertyName().text;
        let sym = new Symbol(source, id, type, null);
        sym.symbolType = 'field';
        this.symbolTable.insert(sym);
    }


    /* === LISTENERS === */
    public enterClassMethod(ctx: ClassMethodContext){
        let tokens = this.parser.inputStream;

        let source = new Source(ctx.start, ctx.stop);
        source.text = tokens.getText(ctx);

        let header = ctx.methodHeader();
        let type = "void";
        if ( header.dataType()!=null ) {
            type = tokens.getText(header.dataType());
        }

        let params = this.generateParametersObject(header.methodParameters());
        let sym = new Symbol(source, header.methodName().text, type, {params: params});
        sym.symbolType = 'method';
        this.symbolTable.insert(sym);
    }

    private generateParametersObject(paramsCtx: MethodParametersContext ){
        let params = [];
        if(!paramsCtx){
            return params;
        }

        paramsCtx.methodParameter().forEach((param)=>{
            params.push(
                {
                    type : param.dataType().text,
                    name : param.methodParameterName().text
                }
            );
        });
        return params;
    }
}
