# apex-parser-ts

A Salesforce Apex parser using [antlr4ts](https://github.com/tunnelvisionlabs/antlr4ts).  VERY MUCH WIP!!!

## Setup

`npm install apex-parser-ts`

## Usage

```typescript
import { ExtractSymbols } from 'apex-parser-ts';
symbolExtractor.findSymbolsFromFile('./src/testing/Demo.cls')
```

## Dev

### To Rebuild visitor classes from grammar

`npm run antlr4ts`

### To run Example

`ts-node src/testing/testProgram`


