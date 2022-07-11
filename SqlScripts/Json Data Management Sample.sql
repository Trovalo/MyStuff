-- key-values property
DECLARE @jdata2 as varchar(200) = '{"colors":{"color-1":"transparent","color-2":"transparent"}}'

SELECT
	JSON_VALUE(@jdata2,'$."colors"."color-1"') AS Color1
	,JSON_VALUE(@jdata2,'$."colors"."color-2"') AS Color2
	,JSON_VALUE(@jdata2,'$."colors"."color-3"') AS Color3
GO

-- objects and arrays
DECLARE @jdata as varchar(200) = '{"company":"Contoso","colors":[{"name": "Red", "color":"#00000"},{"name": "Green", "color":"#00000"}]}'

SELECT JSON_QUERY(@jdata,'$.colors[0]')
SELECT JSON_VALUE(@jdata,'$.colors[0].name')
SELECT JSON_VALUE(@jdata,'$.company')

--Update property
SELECT JSON_MODIFY(@jdata,'$.company', 'Northwind')
--Add property
SELECT JSON_MODIFY(@jdata,'$.country', 'Italy')
--Add new Object
SELECT JSON_MODIFY(@jdata,'$.salesman', JSON_QUERY('{"name":"Mario","surname":"Rossi"}'))
--Append new Object in an Object array
SELECT JSON_MODIFY(@jdata,'append $.colors', JSON_QUERY('{"name":"Yellow", "color":"#00000"}','$'))

------ About DELETING
--Delete (whole) Property works fine
SELECT JSON_MODIFY(@jdata,'$.colors', NULL)
-- deleting sometihng inside an array is not fine at all
-- Should delete 1 value/object from the array... but no, 'null,' is left instead
SELECT JSON_MODIFY(@jdata,'$.colors[1]', NULL)
-- To "delete" properly pass the whole array or object array omitting the deleted value...
SELECT JSON_MODIFY(@jdata,'$.colors', JSON_QUERY('[{"name": "Green", "color":"#00000"}]'))
