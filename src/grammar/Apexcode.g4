/*
 * An Apexcode grammar for ANTLR v4.
 * This file is part of https://github.com/neowit/apexscanner
 *
 * Copyright (c) 2017 Andrey Gavrikov.
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

grammar Apexcode;

/**
 * Parser Rules
 */
// starting point for parsing a apexcode file
compilationUnit
    :   '(hidden)' EOF // allow, but ignore files with managed code
    |   typeDeclaration* EOF
    ;

typeDeclaration
    :   triggerDeclaration                              #triggerDef
    |   classOrInterfaceModifier* classDeclaration      #classDef
    |   classOrInterfaceModifier* interfaceDeclaration  #interfaceDef
    |   enumDeclaration                                 #enumDef
    |   ';'                                             #emptyDef
    ;

// CLASSES
classOrInterfaceModifier
    :   annotation
    |   classOrInterfaceVisibilityModifier
    |   classSharingModifier
    ;

classOrInterfaceVisibilityModifier
    :   PUBLIC     // class or interface
        |   PRIVATE    // class or interface
        |   ABSTRACT   // class or interface
        |   GLOBAL     // class or interface
        |   VIRTUAL     // class or interface
        |   WEBSERVICE // class only -- does not apply to interfaces
    ;

classSharingModifier
    :   WITHOUT_SHARING | WITH_SHARING // class only
    ;

classDeclaration
    :   CLASS className extendsDeclaration? implementsDeclaration?  '{' classBody '}'
    ;

className:  Identifier;

extendsDeclaration
    :   EXTENDS dataType
    ;

implementsDeclaration
    : IMPLEMENTS dataType (',' dataType)*
    ;

classBody
    :   (staticCodeBlock | classBodyMember | blockStatement)*
    ;

classBodyMember
    :   enumDeclaration
    |   classConstructor
    |   classMethod
    |   classVariable
    |   classProperty
    |   typeDeclaration
    ;

classConstructor
    :   (annotation | classConstructorModifier)*
        qualifiedName '(' methodParameters? ')' methodBody
    ;

classConstructorModifier
    :   (PUBLIC | PROTECTED | PRIVATE | GLOBAL)
        | OVERRIDE
        | VIRTUAL
    ;

// INTERFACES & CLASSES

interfaceDeclaration
    :   INTERFACE interfaceName extendsDeclaration? '{' interfaceBody '}'
    ;

interfaceName:  Identifier;

interfaceBody
    :   (methodHeader ';')*
    ;

// TRIGGERS
triggerDeclaration
    :   TRIGGER_KEYWORD triggerName TRIGGER_ON_KEYWORD triggerSObjectType '('
            TRIGGER_EVENT (',' TRIGGER_EVENT)*
        ')' '{' classBody '}'
    ;

triggerName :   Identifier ;

triggerSObjectType :   Identifier ;

// CLASS CONTENT
classVariable
    :   (annotation | classVariableModifier)*
        dataType variableName ('=' expression)? (',' variableName ('=' expression)? )* ';'
    ;

classVariableModifier
    :   (PUBLIC | PROTECTED | PRIVATE | GLOBAL)
       |    FINAL
       |    STATIC
       |    TRANSIENT
       |    WEBSERVICE
    ;

variableName :   Identifier ;


classMethod
    :   methodHeader methodBody
    |   methodHeader ';'    //abstract method
    ;

methodParameters
    :   methodParameter (',' methodParameter)*
    ;

methodParameter
    :   FINAL? dataType methodParameterName
    ;

methodParameterName:  Identifier;

methodHeader
    : (annotation | methodHeaderModifier)*
      dataType methodName '(' methodParameters? ')'
    ;

methodHeaderModifier
    :   (PUBLIC | PROTECTED | PRIVATE | GLOBAL)
       | OVERRIDE
       | ABSTRACT
       | VIRTUAL
       | STATIC
       | TESTMETHOD
       | WEBSERVICE
    ;

methodName
    : Identifier
    ;

methodBody
    :   codeBlock
    ;

classProperty
    :   ( annotation | propertyModifier )*
        dataType propertyName '{' (propertyGet | propertySet)+ '}'
    ;

propertyModifier
     :  (PUBLIC | PROTECTED | PRIVATE | GLOBAL)
        |   FINAL
        |   STATIC
        |   TRANSIENT
    ;
propertyName:   Identifier;

propertyGet
    :   propertyGetSetModifier*
        (GET_EMPTY | GET_OPEN_CURLY  blockStatement* '}')
    ;

propertySet
    :   propertyGetSetModifier*
        (SET_EMPTY | SET_OPEN_CURLY  blockStatement* '}')
    ;

propertyGetSetModifier
    :   (PUBLIC | PROTECTED | PRIVATE | GLOBAL)
        |   STATIC
    ;

// ENUM
enumDeclaration
    :   classOrInterfaceModifier* ENUM enumName '{' enumConstants? '}'
    ;

enumName:   Identifier;

enumConstants
    :   enumConstant (',' enumConstant)*
    ;

enumConstant
    :   Identifier
    ;


// ANNOTATIONS

annotation
    :   '@' annotationName ( '(' ( annotationElementValuePairs | annotationElementValue )? ')' )?
    ;

annotationName : Identifier ;

annotationElementValuePairs
    :   annotationElementValuePair (annotationElementValuePair)*
    ;

annotationElementValuePair
    :   Identifier '=' annotationElementValue
    ;

annotationElementValue
    :   expression
    |   annotation
    ;

expression
    :   primary                                                             #primaryExpr
    |   expression '.' expression                                           #exprDotExpression
    |   func=expression '(' expressionList? ')'                             #methodCallExpr
    |   arr=expression '[' expression ']'                                   #arrayIndexExpr
    |   NEW creator                                                         #creatorExpression
    |   '(' typeArguments ')' expression                                    #typeCastComplexExpr
    |   expression op=('++' | '--')                                         #postIncrementExpr
    |   op=('++'|'--') expression                                           #preIncrementExpr
    |   op=('+'|'-') expression                                             #unaryExpr
    |   op='!' expression                                                   #unaryInequalityExpr
    |   expression op=('*'|'/'|'%') expression                              #infixMulExpr
    |   expression ('+'|'-') expression                                     #infixAddExpr
    |   expression ('<' '<' | '>' '>' '>' | '>' '>') expression             #infixShiftExpr
        // Apex allows '> =' and '< =' instead of '>=' and '<='
    |   expression ('<' WS? '=' | '>' WS? '=' | '>' | '<') expression       #comparisonExpr
    |   expression INSTANCE_OF dataType                                     #instanceOfExpr
    |   expression ('===' | '==' | '!=' | '<>') expression                  #infixEqualityExpr
    |   expression '&' expression                                           #bitwiseAndExpr
    |   expression '^' expression                                           #bitwiseXorExpr
    |   expression '|' expression                                           #bitwiseOrExpr
    |   expression '&&' expression                                          #infixAndExpr
    |   expression '||' expression                                          #infixOrExpr
    |   expression '?' expression ':' expression                            #ternaryExpr
    |   '(' dataType ')' expression                                         #typeCastSimpleExpr
    |   <assoc=right> left=expression
        op=(    '='
        |       '+='
        |       '-='
        |       '*='
        |       '/='
        |       '&='
        |       '|='
        |       '^='
        |       '>>='
        |       '>>>='
        |       '<<='
        )
        right=expression                                                    #assignmentExpr
    ;

primary
    :   parExpression
    |   THIS
    |   SUPER
    |   literal
    |   Identifier
    |   dataType '.' CLASS  //System.Type apexType = List<Integer>.class;
                            //results in: apexType=List<Integer>
                            //can be used like so:
                            //  List<InvoiceStatement> deserializedInvoices =
                            //      (List<InvoiceStatement>)JSON.deserialize(JSONString, List<InvoiceStatement>.class);
    ;

parExpression
    :   '(' expression ')'
    ;

expressionList
    :   expression (',' expression)*
    ;


/* System.runAs(user) { ... test code here ... } */
runas_expression
    :   SYSTEM_RUNAS '(' expressionList? ')' codeBlock
    ;

db_shortcut_expression
    :   DB_MERGE expression expression      #dbShortcutMerge
    |   DB_UPSERT expression expression     #dbShortcutTwoOp
    |   (DB_UPDATE
        | DB_DELETE
        | DB_INSERT
        | DB_UNDELETE
        | DB_UPSERT
        ) expression                        #dbShortcutOneOp
    ;


creator
    :   dataType '(' ')'
    |   dataType parExpression
    |   dataType (classCreatorRest | arrayCreatorRest | mapCreatorRest | setCreatorRest)
    ;

typeArguments
    :   '<' dataType (',' dataType)* '>'
    ;

arrayCreatorRest
    :   '['
        (   ']' ('[' ']')* arrayInitializer
        |   expression ']' ('[' expression ']')* ('[' ']')*
        )
    ;

mapCreatorRest
    :   '{' ( ( literal | expression ) '=>' ( literal | expression ) (',' (literal | expression) '=>' ( literal | expression ) )* )? '}'
    ;

setCreatorRest
	: '{' ( literal | expression ) (',' ( literal | expression ))* '}'
	;

classCreatorRest
    :   arguments
    ;


variableInitializer
    :   arrayInitializer
    |   expression
    ;

arrayInitializer
    :   '{' (variableInitializer (',' variableInitializer)* (',')? )? '}'
    ;

arguments
    :   '(' expressionList? ')'
    ;


// CODE BLOCK & STATEMENT
codeBlock
    :  '{' blockStatement* '}'
    ;

staticCodeBlock
    : STATIC codeBlock
    ;

localVariableDeclaration
    :   localVariableModifier* dataType variableName ('=' expression)? (',' variableName ('=' expression)? )*
    ;

localVariableModifier
    :   FINAL | TRANSIENT
    ;

blockStatement
    :   localVariableDeclaration ';'
    |   statement
    ;

qualifiedName
    :   Identifier ('.' Identifier)*
    ;

forControl
    :   enhancedForControl
    |   forInit? ';' expression? ';' forUpdate?
    ;

forInit
    :   localVariableDeclaration
    |   expressionList
    ;

enhancedForControl
    :   dataType variableName ':' expression
    ;

forUpdate
    :   expressionList
    ;

catchClause
    :   CATCH '(' catchType variableName ')' codeBlock
    ;

catchType
    :   qualifiedName ('|' qualifiedName)*
    ;

finallyBlock
    :   FINALLY codeBlock
    ;

statement
    :   codeBlock                                                   #blockStmt
    |   BREAK ';'                                                   #breakStmt
    |   CONTINUE ';'                                                #continueStmt
    |   DO statement WHILE parExpression ';'                        #doWhileStmt
    |   FOR '(' forControl ')' statement                            #forStmt
    |   IF parExpression statement (ELSE statement)?                #ifElseStmt
    |   RETURN expression? ';'                                      #returnStmt
    |   THROW expression ';'                                        #throwStmt
    |   TRY codeBlock (catchClause+ finallyBlock? | finallyBlock)   #tryCatchFinallyStmt
    |   WHILE parExpression statement                               #whileStmt
    |   ';'                                                         #emptyStmt
    |   runas_expression                                            #runAsStmt
    |   db_shortcut_expression ';'                                  #dbShortcutStmt
    |   expression ';'                                              #expressionStmt
    ;


literal
    :   IntegerLiteral          #intLiteral
    |   FloatingPointLiteral    #fpLiteral
    |   StringLiteral           #strLiteral
    |   BooleanLiteral          #boolLiteral
    |   NULL                    #nullLiteral
    |   SoslLiteral             #soslLiteral
    |   SoqlLiteral             #soqlLiteral
    ;

dataType
    :   VOID
    |   arrayType=qualifiedName '[' ']'
    |   qualifiedName typeArguments?
    ;

/**
 * Lexer Rules
 */

// Whitespace and comments

APEXDOC_COMMENT
    :   '/**' [\r\n] .*? '*/' -> channel(HIDDEN)
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;

WS
    :  [ \t\r\n\u000C]+ -> channel(HIDDEN)
    ;

BooleanLiteral
    :   TRUE
    |   FALSE
    ;

//KEYWORDS
ABSTRACT    : A B S T R A C T;
CLASS       : C L A S S;
ENUM        : E N U M;
EXTENDS     : E X T E N D S;
FALSE       : F A L S E;
FINAL	    : F I N A L ;
NULL        : N U L L;
IMPLEMENTS  : I M P L E M E N T S;
INSTANCE_OF : I N S T A N C E O F;
INTERFACE   : I N T E R F A C E;
OVERRIDE    : O V E R [rR] I D E;
PRIVATE	    : P R I V A T E;
PROTECTED   : P R O T E C T E D;
PUBLIC	    : P U B L I C;
STATIC	    : S T A T I C;
SUPER       : S U P E R;
THIS        : T H I S;
TRANSIENT   : T R A N S I E N T;
TRUE        : T R U E;
VIRTUAL	    : V I R T U A L;
VOID        : V O I D;
NEW         : {this._input.LA(-1) != '.'.charCodeAt(0)}? N E W;

// FLOW CONTROL KEYWORDS
BREAK       : B R E A K;
CONTINUE    : C O N T I N U E;
DO          : D O ;
ELSE        : E L S E;
FOR         : F O R;
IF          : I F;
RETURN      : R E T U R N;
THROW       : T H R O W;
TRY         : T R Y;
CATCH       : C A T C H;
FINALLY     : F I N A L L Y;
WHILE       : W H I L E;


// Apexcode specific
BRACKET_THEN_FIND   : '[' WS? F I N D WS;
BRACKET_THEN_SELECT : '[' WS? S E L E C T WS;
// db shortcut expression must not be preceeded by '.'
DB_DELETE   : {this._input.LA(-1) != '.'.charCodeAt(0)}? DELETE;
DB_INSERT   : {this._input.LA(-1) != '.'.charCodeAt(0)}? INSERT;
DB_MERGE    : {this._input.LA(-1) != '.'.charCodeAt(0)}? MERGE;
DB_UNDELETE : {this._input.LA(-1) != '.'.charCodeAt(0)}? UNDELETE;
DB_UPDATE   : {this._input.LA(-1) != '.'.charCodeAt(0)}? UPDATE;
DB_UPSERT   : {this._input.LA(-1) != '.'.charCodeAt(0)}? UPSERT;

TRIGGER_EVENT   : (BEFORE | AFTER) WS (DELETE | INSERT | MERGE | UNDELETE | UPDATE | UPSERT);

GLOBAL	    : G L O B A L;
SYSTEM_RUNAS: SYSTEM '.' R U N A S;
TRIGGER_KEYWORD : TRIGGER {this._input.LA(1) != '.'.charCodeAt(0)}? ;
TRIGGER_ON_KEYWORD  :   O N;
TESTMETHOD  : T E S T M E T H O D ;
WEBSERVICE  : W E B S E R V I C E;
WITHOUT_SHARING    : WITHOUT WS SHARING;
WITH_SHARING    : WITH WS SHARING;

GET_EMPTY   : GET WS? ';';
GET_OPEN_CURLY   : GET WS? '{';
SET_EMPTY   : SET WS? ';';
SET_OPEN_CURLY   : SET WS? '{';



StringLiteral
    :   '\'' StringCharacters? '\''
    ;

fragment
StringCharacters
    :   StringCharacter+
    ;

fragment
StringCharacter
    :   ~['\\]
    |   EscapeSequence
    ;

// Escape Sequences for Character and String Literals

fragment
EscapeSequence
    :   '\\' [btnfr"'\\]
    ;

// Apex - SOQL && SOSL literals

// [ SELECT ... ]
SoqlLiteral
    : BRACKET_THEN_SELECT (SelectRestNoInnerBrackets | SelectRestAllowingInnerBrackets)*? ']'
	;

// [ FIND ... ]
SoslLiteral
    : BRACKET_THEN_FIND (SelectRestNoInnerBrackets | SelectRestAllowingInnerBrackets)*? ']'
	;

fragment SelectRestAllowingInnerBrackets
	:  '[' ~']' .*? ']'
	|   LINE_COMMENT
	|   COMMENT
	|  '[' ']'  // e.g. [ select ... where field in :new String[] {...} ]
	|	~'[' .*?
	;

fragment SelectRestNoInnerBrackets
	:   LINE_COMMENT
	|   COMMENT
	|  ~'['
	;

// Integer Literals

IntegerLiteral
    :   DecimalIntegerLiteral L? //suffix L makes it Long as opposed to Integer
    ;

fragment
DecimalIntegerLiteral
    :   DecimalNumeral
    ;

fragment
DecimalNumeral
    :   '0'
    |   NonZeroDigit (Digits? | Underscores Digits)
    |   Digits
    ;

fragment
Digits
    :   Digit (DigitOrUnderscore* Digit)?
    ;

fragment
Digit
    :   '0'
    |   NonZeroDigit
    ;

fragment
NonZeroDigit
    :   [1-9]
    ;

fragment
DigitOrUnderscore
    :   Digit
    |   '_'
    ;

fragment
Underscores
    :   '_'+
    ;


// Floating-Point Literals

FloatingPointLiteral
    :   DecimalFloatingPointLiteral
    ;

fragment
DecimalFloatingPointLiteral
    :   Digits '.' Digits?
    |   '.' Digits
    ;

fragment SHARING    : S H A R I N G;
fragment SYSTEM     : S Y S T E M;
fragment TRIGGER    : T R I G G E R;
fragment WITH       : W I T H;
fragment WITHOUT    : W I T H O U T;

fragment BEFORE     : B E F O R E;
fragment AFTER      : A F T E R;
fragment DELETE     : D E L E T E;
fragment INSERT     : I N S E R T;
fragment MERGE      : M E R G E;
fragment UNDELETE   : U N D E L E T E;
fragment UPDATE     : U P D A T E;
fragment UPSERT     : U P S E R T;

fragment GET : G E T;
fragment SET : S E T;

// Identifier must go after all Lexer rules,
// otherwise it conflicts with all case insensitive constants, e.g. PUBLIC, PRIVATE, etc
Identifier
    :   ApexcodeLetter ApexcodeLetterOrDigit*
    ;

// FRAGMENTS
fragment
ApexcodeLetter
    :   [a-zA-Z_]
    ;

fragment
ApexcodeLetterOrDigit
    :   [a-zA-Z0-9_]
    ;


// characters
fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];
fragment SPACE : ' ';

fragment DIGIT : [0-9] ;

