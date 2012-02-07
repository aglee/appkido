-- Gets all header file paths for the specified framework.

select distinct
    header.ZHEADERPATH as headerPath
from ZTOKEN token,
    ZTOKENMETAINFORMATION tokenMeta,
    ZHEADER header
where
    token.ZMETAINFORMATION = tokenMeta.Z_PK
    and tokenMeta.ZDECLAREDIN = header.Z_PK
    and header.ZFRAMEWORKNAME = ?
