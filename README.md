mql
===

MarkLogic Query Language - A  simplified query language for MarkLogic
This is an attempt to build a very simpla and robust query language for converting to cts searches.

The general outline of the query language like this:
```
  and(
    or(
      dir("/foo/bar/","bar",infinity),
      collection("happy","not-happy", "sad")
    ),
     boost(
       and(
          region:equal("Hello"),
          bar:between(18,32),
          bar:gt(18),
          bar:le(23)
     ),bat:equal("not-ready"))
  )
```
That will convert to cts:constructs similar to search:search.  

##Join Expressions
+ and
+ andnot
+ or
+ boost
+ near

##Lexicon Expressions
- (dir|directory)  allow query directory lexicons
- (doc|document)   allow query of uri lexicons 
- (coll|collection) - allow query of collection lexicons

##Operator Expressions
- (eq|equal) - Equality Searches will translate appropriately to cts:value-query or cts:range-query based on how the nodespec is defined
- (ne|notequal) - NotEquality Searches will translate appropriately to cts:not(cts:value-query) or cts:range-query(!=) based on how nodespec is defined
- (ma|matches) - Performs matching query using ? * as wildcards. The underlying query will be dependent on the nodespec definition

##Range Expression
- (bw|between)  - Between searches will support the ability to create ranged queries based on range lexicon values.  
- ge greaterThanEqualTo searches on range value lexicons
- gt greaterThan searches on range value lexicons
- le lessThanEqualTo searches on range value lexicons
- lt lessThan searches on range value lexicons

##Geospatial Query Support 
<p>Geospatial queries will use WKT formats to represent the underlying range values</p>
-geo|geospatial - the geospatial query output will depend on the nodespec definition.  
Shorthand syntax is supported for all WKT functions
+ WKT supports
+ POINT(PT)
+ MULTIPOINT(MPT)
+ LINESTRING(LS)
+ MULTILINESTRING(MLS)
+ POLYGON(PG)
+ MULTIPOLYGON(MPG)
+GEOMETRYCOLLECTION(GC)

<p>More to come</p>
