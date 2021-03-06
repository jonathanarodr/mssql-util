IF (OBJECT_ID('fn_FormatarCNPJ','FN') IS NOT NULL)
    DROP FUNCTION fn_FormatarCNPJ
GO

CREATE FUNCTION fn_FormatarCNPJ (@cCNPJ varchar(14))

RETURNS varchar(18)

AS

BEGIN

    DECLARE @cCNPJFormat varchar(18)

    SET @cCNPJFormat = SUBSTRING(@cCNPJ,1,2) + '.' + SUBSTRING(@cCNPJ,3,3) + '.' + SUBSTRING(@cCNPJ,6,3) + '/' + SUBSTRING(@cCNPJ,9,4) + '-' + SUBSTRING(@cCNPJ,13,2)

    RETURN @cCNPJFormat

END