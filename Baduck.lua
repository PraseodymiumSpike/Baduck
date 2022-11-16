--for Lua 5.4.4
--created with the help of EmmyLua
board_size=19 --should be an integer between 10 and 99, inclusive
print("Enter the value of Komi as a decimal. It should be a half-integer. The default is 7 plus 1/2.")
local komi=io.read()
komi=tonumber(komi) or 15/2
board={}
for x=1,board_size do
 board[x]={}
 for y=1,board_size do
  board[x][y]="+"
 end
end --initializes board
function copy_board()
 local board_copy={}
 for x=1,board_size do
  board_copy[x]={}
  for y=1,board_size do
   board_copy[x][y]=board[x][y]
  end
 end
 return board_copy
end
history={copy_board()}
function print_board()
 for y=board_size,1,-1 do
  if y>=10 then
   io.write(y.." ")
  else
   io.write(y.."  ")
  end
  for x=1,board_size do
   io.write(board[x][y])
  end
  print()
 end
 print()
 io.write("   ")
 for x=1,board_size do
  if x>=10 then
   io.write(string.sub(tostring(x),1,1))
  else
   io.write(" ")
  end
 end
 print()
 io.write("   ")
 for x=1,board_size do
  io.write(string.sub(tostring(x),-1))
 end
 print()
end
function check_stone_legality(x,y)
 return board[x][y]=="+"
end
function assemblage_metamethod(assemblage)
 local assemblage_string=assemblage.color
 for point_number,point in ipairs(assemblage.stones) do
  assemblage_string=assemblage_string.."("..point[1]..","..point[2]..")"
 end
 return assemblage_string
end --converts assemblage to string form
assemblage_metatable={__tostring=assemblage_metamethod}
function new_assemblage(color,point)
 local assemblage={color=color,stones={point}}
 setmetatable(assemblage,assemblage_metatable)
 return assemblage
end
function add_point_to_assemblage(assemblage,point)
 assemblage.stones[#assemblage.stones+1]=point
end
function merge_assemblages(assemblage_list,number_of_first,number_of_second)
 for point_number,point in ipairs(assemblage_list[number_of_second].stones) do
  add_point_to_assemblage(assemblage_list[number_of_first],point)
 end
 assemblage_list[number_of_second]=assemblage_list[#assemblage_list]
 assemblage_list[#assemblage_list]=nil
end
function find_assemblage_number(assemblage_list,point)
 for assemblage_number,assemblage in ipairs(assemblage_list) do
  for point_number,point_candidate in ipairs(assemblage.stones) do
   if point[1]==point_candidate[1] and point[2]==point_candidate[2] then
    return assemblage_number
   end
  end
 end
end
function get_assemblages(board)
 local assemblages={}
 if board[1][1]=="B" then
  assemblages[1]=new_assemblage("Black",{1,1})
 elseif board[1][1]=="W" then
  assemblages[1]=new_assemblage("White",{1,1})
 elseif board[1][1]=="D" then
  assemblages[1]=new_assemblage("Duck",{1,1})
 else
  assemblages[1]=new_assemblage("Empty",{1,1})
 end
 for y=2,board_size do
  if board[1][y]==board[1][y-1] then
   add_point_to_assemblage(assemblages[#assemblages],{1,y})
  else
   if board[1][y]=="B" then
    assemblages[#assemblages+1]=new_assemblage("Black",{1,y})
   elseif board[1][y]=="W" then
    assemblages[#assemblages+1]=new_assemblage("White",{1,y})
   elseif board[1][y]=="D" then
    assemblages[#assemblages+1]=new_assemblage("Duck",{1,y})
   else
    assemblages[#assemblages+1]=new_assemblage("Empty",{1,y})
   end
  end
 end
 for x=2,board_size do
  if board[x][1]==board[x-1][1] then
   add_point_to_assemblage(assemblages[find_assemblage_number(assemblages,{x-1,1})],{x,1})
  else
   if board[x][1]=="B" then
    assemblages[#assemblages+1]=new_assemblage("Black",{x,1})
   elseif board[x][1]=="W" then
    assemblages[#assemblages+1]=new_assemblage("White",{x,1})
   elseif board[x][1]=="D" then
    assemblages[#assemblages+1]=new_assemblage("Duck",{x,1})
   else
    assemblages[#assemblages+1]=new_assemblage("Empty",{x,1})
   end
  end
  for y=2,board_size do
   if board[x][y]==board[x-1][y] then
    add_point_to_assemblage(assemblages[find_assemblage_number(assemblages,{x-1,y})],{x,y})
    local number_of_first=find_assemblage_number(assemblages,{x-1,y})
    if board[x][y]==board[x][y-1] and number_of_first~=find_assemblage_number(assemblages,{x,y-1}) then
     merge_assemblages(assemblages,number_of_first,find_assemblage_number(assemblages,{x,y-1}))
    end
   else
    if board[x][y]==board[x][y-1] then
     add_point_to_assemblage(assemblages[find_assemblage_number(assemblages,{x,y-1})],{x,y})
    else
     if board[x][y]=="B" then
      assemblages[#assemblages+1]=new_assemblage("Black",{x,y})
     elseif board[x][y]=="W" then
      assemblages[#assemblages+1]=new_assemblage("White",{x,y})
     elseif board[x][y]=="D" then
      assemblages[#assemblages+1]=new_assemblage("Duck",{x,y})
     else
      assemblages[#assemblages+1]=new_assemblage("Empty",{x,y})
     end
    end
   end
  end
 end
 return assemblages
end
function assemblage_reaches_color(board,assemblage,color)
 if assemblage.color==color then
  return false
 end
 local symbol
 if color=="Black" then
  symbol="B"
 elseif color=="White" then
  symbol="W"
 elseif color=="Duck" then
  symbol="D"
 else
  symbol="+"
 end
 for stone_number,stone in ipairs(assemblage.stones) do
  if stone[2]<board_size and board[stone[1]][stone[2]+1]==symbol then
   return true
  elseif stone[1]<board_size and board[stone[1]+1][stone[2]]==symbol then
   return true
  elseif stone[2]>1 and board[stone[1]][stone[2]-1]==symbol then
   return true
  elseif stone[1]>1 and board[stone[1]-1][stone[2]]==symbol then
   return true
  end
 end
 return false
end
function updated_board(stone_x,stone_y,duck_x,duck_y)
 local board_copy=copy_board()
 if player=="Black" then
  board_copy[stone_x][stone_y]="B"
 else
  board_copy[stone_x][stone_y]="W"
 end
 for x=1,board_size do
  for y=1,board_size do
   if board_copy[x][y]=="D" then
    board_copy[x][y]="+"
   end
  end
 end
 board_copy[duck_x][duck_y]="D"
 if player=="Black" then
  for assemblage_number,assemblage in ipairs(get_assemblages(board_copy)) do
   if assemblage.color=="White" and not assemblage_reaches_color(board_copy,assemblage,"Empty") then
    for stone_number,stone in ipairs(assemblage.stones) do
     board_copy[stone[1]][stone[2]]="+"
    end
   end
  end
 else
  for assemblage_number,assemblage in ipairs(get_assemblages(board_copy)) do
   if assemblage.color=="Black" and not assemblage_reaches_color(board_copy,assemblage,"Empty") then
    for stone_number,stone in ipairs(assemblage.stones) do
     board_copy[stone[1]][stone[2]]="+"
    end
   end
  end
 end --removes captured stones
 return board_copy
end
function check_turn_legality(stone_x,stone_y,duck_x,duck_y)
 if board[duck_x][duck_y]~="+" then
  return false
 end --filters out attempts to move the Duck to an occupied Point
 if stone_x==duck_x and stone_y==duck_y then
  return false
 end --filters out attempts to move the Duck to a Point that a Stone was just Placed
 local board_candidate=updated_board(stone_x,stone_y,duck_x,duck_y)
 for assemblage_number,assemblage in ipairs(get_assemblages(board_candidate)) do
  if assemblage.color==player and not assemblage_reaches_color(board_candidate,assemblage,"empty") then
   return false
  end
 end
 local match_found=false
 for past_board_number,past_board in ipairs(history) do
  local is_match=true
  for x=1,board_size do
   for y=1,board_size do
    local equivalent_points=true
    if board_candidate[x][y]~=past_board[x][y] then
     equivalent_points=false
    end
    if board_candidate[x][y]=="D" and past_board[x][y]=="+" then
     equivalent_points=true
    end
    if board_candidate[x][y]=="+" and past_board[x][y]=="D" then
     equivalent_points=true
    end
    if not equivalent_points then
     is_match=false
     break
    end
   end
  end
  if is_match then
   match_found=true
   break
  end
 end
 if match_found then
  return false
 end --filters out attempts to violate positional superko rule
 return true
end --TO BE DONE
function coordinate_form(text)
 if string.find(text,"(%d,%d)") then
  return true
 end
 if string.find(text,"(%d%d,%d)") then
  return true
 end
 if string.find(text,"(%d,%d%d)") then
  return true
 end
 if string.find(text,"(%d%d,%d%d)") then
  return true
 end
end
local pass_number=0
player="Black"
print_board()
while pass_number~=2 do
 local legality=false
 repeat
  print("It is "..player.."'s turn. If the Board was not shown just before this line, there was an invalid entry.")
  print("Enter the coordinates at which you would like to Place your Stone in the form (x,y) or enter \"Pass\".")
  local entry=io.read()
  if entry=="Pass" then
   pass_number=pass_number+1
   legality=true
  else
   if coordinate_form(entry) then
    local x=tonumber(string.sub(entry,2,string.find(entry,",")-1))
    local y=tonumber(string.sub(entry,string.find(entry,",")+1,-2))
    if x>=1 and x<=board_size and y>=1 and y<=board_size and check_stone_legality(x,y) then
     print("Enter the coordinates of the Point onto which you would like to Move the Duck in the form (x,y).")
     local duck_entry=io.read()
     if coordinate_form(duck_entry) then
      local duck_x=tonumber(string.sub(duck_entry,2,string.find(duck_entry,",")-1))
      local duck_y=tonumber(string.sub(duck_entry,string.find(duck_entry,",")+1,-2))
      if check_turn_legality(x,y,duck_x,duck_y) then
       board=updated_board(x,y,duck_x,duck_y)
       legality=true
       pass_number=0
      end
     end
    end
   end
  end
 until legality
 history[#history+1]=copy_board()
 if player=="Black" then
  player="White"
 else
  player="Black"
 end
 if pass_number~=2 then
  print_board()
 end
end --main gameplay loop
for x=1,board_size do
 for y=1,board_size do
  if board[x][y]=="D" then
   board[x][y]="+"
  end
 end
end --removes Duck
history[#history+1]=copy_board()
print_board()
local black_score=0
local white_score=komi
for assemblage_number,assemblage in ipairs(get_assemblages(board)) do
 if assemblage.color=="Black" then
  black_score=black_score+#assemblage.stones
 elseif assemblage.color=="White" then
  white_score=white_score+#assemblage.stones
 else
  if assemblage_reaches_color(board,assemblage,"Black") and not assemblage_reaches_color(board,assemblage,"White") then
   black_score=black_score+#assemblage.stones
  end
  if assemblage_reaches_color(board,assemblage,"White") and not assemblage_reaches_color(board,assemblage,"Black") then
   white_score=white_score+#assemblage.stones
  end
 end
end
print("Black's Score: "..black_score)
print("White's Score: "..white_score)
if black_score>white_score then
 print("Black wins the game!")
elseif black_score==white_score then
 print("It's a tie. This isn't really supposed to happen. Did you set Komi to an integer instead of a half-integer?")
else
 print("White wins the game!")
end
print("Press Enter to exit.")
io.read()