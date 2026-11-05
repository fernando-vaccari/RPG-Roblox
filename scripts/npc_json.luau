local function json(v)
 if type(v)=='string' then
  return '"'..string.gsub(v,'[%z\1-\31\\"]',function(c)if c=='"'then return '\\"'elseif c=='\\'then return '\\\\'else return string.format('\\u%04x',string.byte(c))end end)..'"'
 end
 if type(v)=='number' then assert(v==v and math.abs(v)<math.huge);return string.format('%.17g',v)end
 if type(v)=='boolean' then return tostring(v)end
 if v==nil then return 'null'end
 local out={};if #v>0 then for _,item in v do table.insert(out,json(item))end;return '['..table.concat(out,',')..']'end
 local keys={};for key in v do table.insert(keys,key)end;table.sort(keys)
 for _,key in keys do table.insert(out,json(key)..':'..json(v[key]))end;return '{'..table.concat(out,',')..'}'
end
