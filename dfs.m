function dfs(I, y, x, dy, dx, T_l, Di)
    global visited;
    if visited(y, x)
        return;
    end
    visited(y, x) = 1;
    for dir = Di(y,x):4:Di(y,x)+4
        x1 = x + dx(dir);
        y1 = y + dy(dir);
        if  y1 < 1 || y1 > size(visited,1) || x1 < 1 || x1 > size(visited,2)
            continue;
        end
        if (I(y1,x1) > T_l)
            dfs(I, y, x, dy, dx, T_l, Di)
        end
    end
end