local opt = { noremap = true, silent = true }

--- @param name string
--- @return boolean
function _G.__check_exec(name)
    return vim.fn.executable(name) == 1
end

function _G.__key_bind(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opt)
end

--- @param arr1 any[]
--- @param arr2 any[]
function _G.__tbl_merge(arr1, arr2)
    local unique_set = {}
    local merged_array = {}

    if arr1 then
        -- 合并并去重 arr1
        for _, value in pairs(arr1) do
            if not unique_set[value] then
                table.insert(merged_array, value)
                unique_set[value] = true
            end
        end
    end

    if arr2 then
        -- 合并并去重 arr2
        for _, value in pairs(arr2) do
            if not unique_set[value] then
                table.insert(merged_array, value)
                unique_set[value] = true
            end
        end
    end

    return merged_array
end
