-- Gets the doc file paths for the specified class name.  There should only be one.

select distinct
    filePath.ZPATH as docPath
from
    ZTOKEN token,
    ZTOKENTYPE tokenType,
    ZTOKENMETAINFORMATION tokenMeta,
    ZFILEPATH filePath
where
    token.ZTOKENNAME = ?
    and token.ZTOKENTYPE = tokenType.Z_PK and tokenType.ZTYPENAME = "cl"
    and token.ZMETAINFORMATION = tokenMeta.Z_PK and tokenMeta.ZFILE = filePath.Z_PK
