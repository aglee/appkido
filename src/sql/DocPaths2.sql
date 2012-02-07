-- Unfortunately s_docPathsQueryTemplate doesn't get all the doc paths we want, because some rows
-- in ZTOKENMETAINFORMATION are missing a ZDECLAREDIN foreign key (to the ZHEADER table), which we
-- need to be able to tell what framework a token is in, because ZFRAMEWORKNAME is in ZHEADER.
--
-- As a workaround, we make a second query using s_docPathsSecondQueryTemplate, which looks for
-- tokens where ZDECLAREDIN is null and the doc path contains the framework name as a component.
-- For example, we assume any tokens documented in .../CoreData/... are in the CoreData framework.
-- This reasoning isn't perfect, but it does pick up, for example, NSFetchedResultsControllerDelegate,
-- thus fixing <https:--github.com/aglee/appkido/issues/3>.
--
-- Note: the placeholders must be in the same order as in s_docPathsQueryTemplate.

select distinct
    filePath.ZPATH as docPath
from
    ZTOKEN token,
    ZTOKENTYPE tokenType,
    ZTOKENMETAINFORMATION tokenMeta,
    ZFILEPATH filePath
where
    token.ZTOKENTYPE = tokenType.Z_PK
    and token.ZMETAINFORMATION = tokenMeta.Z_PK
    and tokenMeta.ZFILE = filePath.Z_PK
    and filePath.ZPATH like '%/' || ? || '/%'
    and tokenType.ZTYPENAME in (?, ?, ?, ?)
