-- LCD big numbers and symbols
local bgnum, module = {}, ...

lcd = require("lcd")

function bgnum.write(text, cols)
  -- Write the text, big, at columns 'cols'
  package.loaded[module] = nil
  -- Define the big digits, if needed
  if BIG_CHARS ~= "bgnum" then
    lcd:defchar(0, "1f1f1f0000000000")
    lcd:defchar(1, "00000000001f1f1f")
    lcd:defchar(2, "1f1f000000001f1f")
    lcd:defchar(3, "1f1f000000000000")
    lcd:defchar(4, "0000000000001f1f")
    lcd:defchar(5, "0000010303010000")
    lcd:defchar(6, "0000101818100000")
    lcd:defchar(7, "0000000000000000")
    BIG_CHARS = "bgnum"
  end
  -- Define the composing chars
  local data = {}
  data["0"] = {"\255\003\255", "\255\004\255"}
  data["1"] = {"\000\255\032", "\001\255\001"}
  data["2"] = {"\000\002\255", "\255\004\001"}
  data["3"] = {"\000\002\255", "\001\004\255"}
  data["4"] = {"\255\004\255", "\032\032\255"}
  data["5"] = {"\255\002\000", "\001\004\255"}
  data["6"] = {"\255\002\000", "\255\004\255"}
  data["7"] = {"\000\003\255", "\032\032\255"}
  data["8"] = {"\255\002\255", "\255\004\255"}
  data["9"] = {"\255\002\255", "\001\004\255"}
  data["C"] = {"\255\003\000", "\255\004\001"}
  data["-"] = {"\032\001\001", "\032\032\032"}
  data[" "] = {"\032\032\032", "\032\032\032"}
  data[":"] = {"\005\006", "\005\006"}
  data["."] = {"\032\032", "\005\006"}
  data["'"] = {"\005\006", "\032\032"}
  data["%"] = {"\005\006\001\000", "\001\000\005\006"}
  -- Write each digit at specific column
  lcd:cls()
  for idx,col in ipairs(cols) do
    local char = text:sub(idx, idx)
    lcd:bigwrite(data[char][1], data[char][2], col)
  end
  return true
end

return bgnum
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
