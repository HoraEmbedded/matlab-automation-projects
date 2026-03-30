function tf = hasToolboxLocal(toolboxName)
%HASTOOLBOXLOCAL Vérifie la présence d'un toolbox via ver.
    v = ver;
    names = string({v.Name});
    tf = any(contains(lower(names), lower(toolboxName)));
end
