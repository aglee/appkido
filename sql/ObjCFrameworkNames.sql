-- Gets the names of all frameworks containing Objective-C classes and protocols.

select distinct
    header.ZFRAMEWORKNAME
from
    ZTOKEN token,
    ZTOKENTYPE tokenType,
    ZTOKENMETAINFORMATION tokenMeta,
    ZHEADER header,
    ZAPILANGUAGE language
where
    token.ZLANGUAGE = language.Z_PK
    and language.ZFULLNAME = 'Objective-C'
    and token.ZTOKENTYPE = tokenType.Z_PK
    and token.ZMETAINFORMATION = tokenMeta.Z_PK
    and tokenMeta.ZDECLAREDIN = header.Z_PK
    and tokenType.ZTYPENAME in ('cl', 'intf')
order by
    header.ZFRAMEWORKNAME
