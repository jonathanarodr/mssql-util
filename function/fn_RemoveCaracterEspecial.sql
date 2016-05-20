CREATE FUNCTION fn_RemoveCaracterEspecial (@cString varchar(max))
 
RETURNS varchar(max)

AS 

BEGIN 

    DECLARE @cNovaString varchar(max)

    --
    -- remove caracter especial 
    -- ex.: 1� por 1o
    --
    SET @cNovaString = @cString COLLATE SQL_LATIN1_GENERAL_CP1250_CI_AS
    
    --
    -- remove acentua��o 
    -- ex.: � por a
    --
    SET @cNovaString = @cNovaString COLLATE SQL_LATIN1_GENERAL_CP1251_CI_AS
    
    RETURN @cNovaString

END