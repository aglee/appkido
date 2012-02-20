-- Gets the names of all frameworks in the docset.

select distinct
    ZFRAMEWORKNAME
from
    ZHEADER
order by
    ZFRAMEWORKNAME
