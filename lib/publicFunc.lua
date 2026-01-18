Public = {}

function Public.deepCopy(object)
    -- 已经复制过的table，key为复制源table，value为复制后的table
    -- 为了防止table中的某个属性为自身时出现死循环
    -- 避免本该是同一个table的属性，在复制时变成2个不同的table
    local lookup_table = {}
    local function _copy(_object)
        if type(_object) ~= 'table' then -- 非table类型直接返回
            return _object
        elseif lookup_table[_object] then
            return lookup_table[_object]
        end
        local new_table = {}
        lookup_table[_object] = new_table
        for k,v in pairs(_object) do
            new_table[_copy(k)] = _copy(v) 
        end
        return setmetatable(new_table, getmetatable(_object))
    end
    return _copy(object)
end

function Public.dumpTable(table,name)
    print("\n[",name,"]",table)
    for key,v1 in pairs(table)do
        print(key,type(key),'=',v1)
        if type(v1) == 'table' then
            print(key,type(key)," = {")
            for j,v2 in pairs(v1)do
            print("   ",j,"=",v2)
            end
            print("}")
        end
    end
    print()
end

return Public