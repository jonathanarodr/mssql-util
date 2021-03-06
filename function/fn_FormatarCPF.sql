IF (OBJECT_ID('fn_FormatarCPF','FN') IS NOT NULL)
    DROP FUNCTION fn_FormatarCPF
GO

CREATE FUNCTION fn_FormatarCPF (@cCPF varchar(11))

RETURNS varchar(14)

AS

BEGIN

    DECLARE @cCPFFormat varchar(14)

    SET @cCPFFormat = SUBSTRING(@cCPF,1,3) + '.' + SUBSTRING(@cCPF,4,3) + '.' + SUBSTRING(@cCPF,7,3) + '-' + SUBSTRING(@cCPF,10,2)

    RETURN @cCPFFormat

END

