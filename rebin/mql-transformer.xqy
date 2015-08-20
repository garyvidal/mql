xquery version "1.0-ml";
(:~
 : Parser Transformer for mql
~:)    
module namespace transform = "mql-transform";

(:~
 : Map of all overriding visitor functions
~:)
declare variable $transform-functions := map:map();

(:~
 : Main Typeswitch Processor 
~:)
declare function transform:transform( 
    $node as node(),
    $options as element(options)
) {
    typeswitch ($node)
     case element(mql) return transform:mql($node,$options)
     case element(mqlExpr) return transform:mqlExpr($node,$options)
     case element(andExpr) return transform:andExpr($node,$options)
     case element(orExpr) return transform:orExpr($node,$options)
     case element(notExpr) return transform:notExpr($node,$options)
     case element(andNotExpr) return transform:andNotExpr($node,$options)
     case element(nearExpr) return transform:nearExpr($node,$options)
     case element(boostExpr) return transform:boostExpr($node,$options)
     case element(fragmentExpr) return transform:fragmentExpr($node,$options)
     case element(propertyExpr) return transform:propertyExpr($node,$options)
     case element(dirExpr) return transform:dirExpr($node,$options)
     case element(documentExpr) return transform:documentExpr($node,$options)
     case element(collectionExpr) return transform:collectionExpr($node,$options)
     case element(equalExpr) return transform:equalExpr($node,$options)
     case element(notEqualExpr) return transform:notEqualExpr($node,$options)
     case element(betweenExpr) return transform:betweenExpr($node,$options)
     case element(matchExpr) return transform:matchExpr($node,$options)
     case element(containsExpr) return transform:containsExpr($node,$options)
     case element(valueExpr) return transform:valueExpr($node,$options)
     case element(wordExpr) return transform:wordExpr($node,$options)
     case element(rangeExpr) return transform:rangeExpr($node,$options)
     case element(equalParams) return transform:equalParams($node,$options)
     case element(equalParam) return transform:equalParam($node,$options)
     case element(nearParams) return transform:nearParams($node,$options)
     case element(nearParam) return transform:nearParam($node,$options)
     case element(geoParams) return transform:geoParams($node,$options)
     case element(geoParam) return transform:geoParam($node,$options)
     case element(rangeParams) return transform:rangeParams($node,$options)
     case element(rangeParam) return transform:rangeParam($node,$options)
     case element(valueParams) return transform:valueParams($node,$options)
     case element(valueParam) return transform:valueParam($node,$options)
     case element(wordParams) return transform:wordParams($node,$options)
     case element(wordParam) return transform:wordParam($node,$options)
     case element(betweenParams) return transform:betweenParams($node,$options)
     case element(andParam) return transform:andParam($node,$options)
     case element(tokenExpr) return transform:tokenExpr($node,$options)
     case element(rangeOperator) return transform:rangeOperator($node,$options)
     case element(distanceWeightParam) return transform:distanceWeightParam($node,$options)
     case element(langParam) return transform:langParam($node,$options)
     case element(collationParam) return transform:collationParam($node,$options)
     case element(minOccursParam) return transform:minOccursParam($node,$options)
     case element(maxOccursParam) return transform:maxOccursParam($node,$options)
     case element(weightParam) return transform:weightParam($node,$options)
     case element(proximityParam) return transform:proximityParam($node,$options)
     case element(orderParam) return transform:orderParam($node,$options)
     case element(depthParam) return transform:depthParam($node,$options)
     case element(geospatialExpr) return transform:geospatialExpr($node,$options)
     case element(pointExpr) return transform:pointExpr($node,$options)
     case element(multiPointExpr) return transform:multiPointExpr($node,$options)
     case element(lineStringExpr) return transform:lineStringExpr($node,$options)
     case element(multiLineStringExpr) return transform:multiLineStringExpr($node,$options)
     case element(polygonExpr) return transform:polygonExpr($node,$options)
     case element(multiPolygonExpr) return transform:multiPolygonExpr($node,$options)
     case element(geometryCollectionExpr) return transform:geometryCollectionExpr($node,$options)
     case element(regionValue) return transform:regionValue($node,$options)
     case element(stringValue) return transform:stringValue($node,$options)
     default return fn:error(xs:QName("UNKNOWN-VISITOR"),"Unknown",$node)
};

declare function transform:nodeSpecQueryType(
    $nodeSpec as element(nodeSpec)
) {
       if($nodespec/element) then "element"       
       else if($nodespec/element-attribute) then "element-attribute"
       else if($nodespec/field) then "field"
       else if($nodespec/path) then "path"
       else if($nodespec/geo-element) then "geo-element"
       else if($nodespec/geo-element-attribute) then "geo-element-attribute"
       else if($nodespec/geo-element-child) then "geo-element-child"
       else fn:error(xs:QName("INVALID-RANGE-NODESPEC"),"Invalid Range nodespec must contain element(element|element-attribute|field|path|geo-element|geo-element-attribute|geo-element-child")
};
declare function transform:range-query(
    $node,
    $operator,
    $values,
    $nodespec
) {

};
declare function transform:nodeSpec($node,$options) {
  fn:replace($node,":$","")
};

declare function transform:stringValue(
 $node as element(stringValue),
 $options as element(options)
) {
   fn:replace($node,"^&quot;|&quot;$","")
};
(:~
 : Transformation Production mql parsed node
~:)
declare function transform:mql(
    $node as element(mql),
    $options as element(options)
) {
   if($options/joiner = "and")
   then cts:and-query((
     transform:transform($node/mqlExpr,$options) 
   )) 
   else if($options/joiner ="or") 
   then  cts:or-query((
     transform:transform($node/mqlExpr,$options)    
   )) else cts:and-query((
        transform:transform($node/mqlExpr,$options) 
   ))
};

(:~
 : Transformation Production mqlExpr parsed node
~:)
declare function transform:mqlExpr(
    $node as element(mqlExpr),
    $options as element(options)
) {
  transform:transform($node/node(),$options)
};

(:~
 : Transformation Production andExpr parsed node
~:)
declare function transform:andExpr(
    $node as element(andExpr),
    $options as element(options)
) {
  cts:and-query((
    for $mql in $node/mqlExpr
    return 
       transform:transform($mql,$options)
  ),
  if($node/andParams) 
  then fn:string($node/andParams)
  else ()
  )
};

(:~
 : Transformation Production orExpr parsed node
~:)
declare function transform:orExpr(
    $node as element(orExpr),
    $options as element(options)
) {
  cts:or-query((
    for $mql in $node/mqlExpr
    return
       transform:transform($mql,$options)
  ))
};

(:~
 : Transformation Production notExpr parsed node
~:)
declare function transform:notExpr(
    $node as element(notExpr),
    $options as element(options)
) {
  cts:not-query(transform:transform($node/mqlExpr,$options))
};

(:~
 : Transformation Production andNotExpr parsed node
~:)
declare function transform:andNotExpr(
    $node as element(andNotExpr),
    $options as element(options)
) {
  cts:and-not-query(
    transform:transform($node/mqlExpr[1],$options),
    transform:transform($node/mqlExpr[2],$options)
  )
};

(:~
 : Transformation Production nearExpr parsed node
~:)
declare function transform:nearExpr(
    $node as element(nearExpr),
    $options as element(options)
) {
   cts:near-query(
      for $mqlExpr in $node/mqlExpr return transform:transform($mqlExpr,$options),
      if($node/nearParams/proximityParam)
      then $node/nearParams/proximityParam/intValue/xs:double(.)
      else 10,
      if($node/nearParams/orderParam)
      then fn:string($node/orderParam)
      else (),
      if($node/nearParams/distanceWeightParam) 
      then () 
      else ()
   )
};

(:~
 : Transformation Production boostExpr parsed node
~:)
declare function transform:boostExpr(
    $node as element(boostExpr),
    $options as element(options)
) {
  let $func := 
    if(fn:starts-with(xdmp:version(),"7"))
    then xdmp:function(xs:QName("cts:boost-query"))
    else ()
  return
  if(fn:exists($func) )
  then xdmp:apply(
    $func,
    transform:transform($node/mqlExpr[1],$options),
    transform:transform($node/mqlExpr[2],$options)
  )
  else fn:error(xs:QName("NOT-SUPPORTED-VERSION"),"boost-query is not supported in " || xdmp:version())
};

(:~
 : Transformation Production fragmentExpr parsed node
~:)
declare function transform:fragmentExpr(
    $node as element(fragmentExpr),
    $options as element(options)
) {
  cts:document-fragment-query(
    transform:transform($node/mqlExpr,$options)
  )
};

(:~
 : Transformation Production propertyExpr parsed node
~:)
declare function transform:propertyExpr(
    $node as element(propertyExpr),
    $options as element(options)
) {
  cts:properties-query(
    transform:transform($node/mqlExpr,$options)
  )
};

(:~
 : Transformation Production dirExpr parsed node
~:)
declare function transform:dirExpr(
    $node as element(dirExpr),
    $options as element(options)
) {
  cts:directory-query(
    for $dir in $node/stringValue
    return
      fn:replace($dir,'^&quot;|&quot;$',""),
    $node/depthParam/xs:string(.)
  )
};

(:~
 : Transformation Production documentExpr parsed node
~:)
declare function transform:documentExpr(
    $node as element(documentExpr),
    $options as element(options)
) {
cts:document-query(
    for $doc in $node/stringValue
    return
      fn:replace($doc,'^&quot;|&quot;$',"")
  )
};

(:~
 : Transformation Production collectionExpr parsed node
~:)
declare function transform:collectionExpr(
    $node as element(collectionExpr),
    $options as element(options)
) {
   cts:collection-query(
    for $coll in $node/stringValue
    return
      fn:replace($coll,'^&quot;|&quot;$',"")
  )
};

(:~
 : Transformation Production equalExpr parsed node
~:)
declare function transform:equalExpr(
    $node as element(equalExpr),
    $options as element(options)
) {
  let $name := transform:nodeSpec($node/nodeSpec,$options)
  let $nodespec := $options/nodespec[@name = $name]
  return
     if($nodespec/@type = "range")
     then 
        cts:element-range-query(xs:QName($name),"=",
            for $token in $node/tokenExpr
            return transform:transform($token,$options)
        ,
        if($node/rangeParams) 
        then transform:rangeParams($node/rangeParams,$options)
        else ()
        )
     else ()  
};

(:~
 : Transformation Production notEqualExpr parsed node
~:)
declare function transform:notEqualExpr(
    $node as element(notEqualExpr),
    $options as element(options)
) {
  let $name := transform:nodeSpec($node/nodeSpec,$options)
  let $nodespec := $options/nodespec[@name = $name]
  let $values :=             
        for $token in $node/tokenExpr
        return transform:transform($token,$options)
  let $opts := 
        if($node/rangeParams) 
        then transform:rangeParams($node/rangeParams,$options)
        else ()
  return
     if($nodespec/@type = "range")
     then
       if($nodespec/element) then      
            cts:element-range-query(xs:QName($name),"!=",$values,$opts)
       else if($nodespec/element-attribute) then ()
       else if($nodespec/field) then ()
       else if($nodespec/path) then ()
       else if($nodespec/geo-element) then ()
       else if($nodespec/geo-element-attribute) then ()
       else if($nodespec/geo-element-child) then ()
       else fn:error(xs:QName("INVALID-RANGE-NODESPEC"),"Invalid Range nodespec must contain element(element|element-attribute|field|path|geo-element|geo-element-attribute|geo-element-child")
     else ()  
};

(:~
 : Transformation Production betweenExpr parsed node
~:)
declare function transform:betweenExpr(
    $node as element(betweenExpr),
    $options as element(options)
) {
  let $name := fn:replace($node/nodeSpec,":","")
  let $nodespec := $options/nodespec[@name = $name]
  let $range := ($node/betweenParams,"inclusive")[1]
  let $oper := 
    if($range = "inclusive") then (">=","<=")
    else (">", "<")
  return
     if($nodespec/@type = "range")
     then cts:and-query((
        cts:element-range-query(xs:QName($name),$oper[1],
            transform:tokenExpr($node/tokenExpr[1],$options)
        ), 
        cts:element-range-query(xs:QName($name),$oper[2],
            transform:tokenExpr($node/tokenExpr[1],$options)
        )
        ))
     else fn:error(xs:QName("UNSUPPORTED-RANGE-NODESPEC"),"Nodespec variable type must be range") 
};

(:~
 : Transformation Production valueExpr parsed node
~:)
declare function transform:valueExpr(
    $node as element(valueExpr),
    $options as element(options)
) {
  let $name := fn:replace($node/nodeSpec,":","")
  let $nodespec := $options/nodespec[@name = $name]
  let $range := ($node/betweenParams,"inclusive")[1]
  let $oper := 
    if($range = "inclusive") then (">=","<=")
    else (">", "<")
  return
     if($nodespec/@type = "range")
     then cts:and-query((
        cts:element-value-query(xs:QName($name),$oper[1],
            transform:tokenExpr($node/tokenExpr[1],$options)
        ), 
        cts:element-range-query(xs:QName($name),$oper[2],
            transform:tokenExpr($node/tokenExpr[1],$options)
        )
        ))
     else fn:error(xs:QName("UNSUPPORTED-RANGE-NODESPEC"),"Nodespec variable type must be range") 
};

(:~
 : Transformation Production wordExpr parsed node
~:)
declare function transform:wordExpr(
    $node as element(wordExpr),
    $options as element(options)
) {
   ()
};

(:~
 : Transformation Production rangeExpr parsed node
~:)
declare function transform:rangeExpr(
    $node as element(rangeExpr),
    $options as element(options)
) {
  let $name := transform:transform($node/nodeSpec,$options)
  let $nodespec := $options/nodespec[@name = $name]
  let $oper := fn:string($node/rangeOperator)
  return
    
      
};

(:~
 : Transformation Production equalParams parsed node
~:)
declare function transform:equalParams(
    $node as element(equalParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production equalParam parsed node
~:)
declare function transform:equalParam(
    $node as element(equalParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production nearParams parsed node
~:)
declare function transform:nearParams(
    $node as element(nearParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production nearParam parsed node
~:)
declare function transform:nearParam(
    $node as element(nearParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production geoParams parsed node
~:)
declare function transform:geoParams(
    $node as element(geoParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production geoParam parsed node
~:)
declare function transform:geoParam(
    $node as element(geoParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production rangeParams parsed node
~:)
declare function transform:rangeParams(
    $node as element(rangeParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production rangeParam parsed node
~:)
declare function transform:rangeParam(
    $node as element(rangeParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production valueParams parsed node
~:)
declare function transform:valueParams(
    $node as element(valueParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production valueParam parsed node
~:)
declare function transform:valueParam(
    $node as element(valueParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production wordParams parsed node
~:)
declare function transform:wordParams(
    $node as element(wordParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production wordParam parsed node
~:)
declare function transform:wordParam(
    $node as element(wordParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production betweenParams parsed node
~:)
declare function transform:betweenParams(
    $node as element(betweenParams),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production andParam parsed node
~:)
declare function transform:andParam(
    $node as element(andParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production tokenExpr parsed node
~:)
declare function transform:tokenExpr(
    $node as element(tokenExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production rangeOperator parsed node
~:)
declare function transform:rangeOperator(
    $node as element(rangeOperator),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production distanceWeightParam parsed node
~:)
declare function transform:distanceWeightParam(
    $node as element(distanceWeightParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production langParam parsed node
~:)
declare function transform:langParam(
    $node as element(langParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production collationParam parsed node
~:)
declare function transform:collationParam(
    $node as element(collationParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production minOccursParam parsed node
~:)
declare function transform:minOccursParam(
    $node as element(minOccursParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production maxOccursParam parsed node
~:)
declare function transform:maxOccursParam(
    $node as element(maxOccursParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production weightParam parsed node
~:)
declare function transform:weightParam(
    $node as element(weightParam),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production proximityParam parsed node
~:)
declare function transform:proximityParam(
    $node as element(proximityParam),
    $options as element(options)
) {
  "proximity=" || $node/TOKEN[3]
};

(:~
 : Transformation Production orderParam parsed node
~:)
declare function transform:orderParam(
    $node as element(orderParam),
    $options as element(options)
) {
  fn:string($node)
};

(:~
 : Transformation Production depthParam parsed node
~:)
declare function transform:depthParam(
    $node as element(depthParam),
    $options as element(options)
) {
    fn:string($node)
};

(:~
 : Transformation Production geospatialExpr parsed node
~:)
declare function transform:geospatialExpr(
    $node as element(geospatialExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production pointExpr parsed node
~:)
declare function transform:pointExpr(
    $node as element(pointExpr),
    $options as element(options)
) {
    cts:point(
       xs:int($node/TOKEN[1]),
       xs:int($node/TOKEN[3])
    ) 
};

(:~
 : Transformation Production multiPointExpr parsed node
~:)
declare function transform:multiPointExpr(
    $node as element(multiPointExpr),
    $options as element(options)
) {
  for $point in $node/pointExpr
  return 
    transform:pointExpr($point,$options)
};

(:~
 : Transformation Production lineStringExpr parsed node
~:)
declare function transform:lineStringExpr(
    $node as element(lineStringExpr),
    $options as element(options)
) {
   cts:linestring(
     for $point in $node/pointExpr
     return 
       transform:pointExpr($point,$options)
   )
};

(:~
 : Transformation Production multiLineStringExpr parsed node
~:)
declare function transform:multiLineStringExpr(
    $node as element(multiLineStringExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production polygonExpr parsed node
~:)
declare function transform:polygonExpr(
    $node as element(polygonExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production multiPolygonExpr parsed node
~:)
declare function transform:multiPolygonExpr(
    $node as element(multiPolygonExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production geometryCollectionExpr parsed node
~:)
declare function transform:geometryCollectionExpr(
    $node as element(geometryCollectionExpr),
    $options as element(options)
) {
  ()
};

(:~
 : Transformation Production regionValue parsed node
~:)
declare function transform:regionValue(
    $node as element(regionValue),
    $options as element(options)
) {
  ()
};
