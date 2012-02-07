-- Gets all doc file paths for up to four token types within the specified framework.
-- Or rather, *should* get. See DocPaths2.sql.

select distinct
    filePath.ZPATH as docPath
from
    ZTOKEN token,
    ZTOKENTYPE tokenType,
    ZTOKENMETAINFORMATION tokenMeta,
    ZHEADER header,
    ZFILEPATH filePath
where
    token.ZTOKENTYPE = tokenType.Z_PK
    and token.ZMETAINFORMATION = tokenMeta.Z_PK
    and tokenMeta.ZFILE = filePath.Z_PK
    and tokenMeta.ZDECLAREDIN = header.Z_PK
    and header.ZFRAMEWORKNAME = ?
    and tokenType.ZTYPENAME in (?, ?, ?, ?)
