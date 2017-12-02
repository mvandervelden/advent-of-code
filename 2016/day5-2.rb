require 'digest/md5'

door_id = "abbhdwsy"
start = "00000"

pwd = "        "
int = 0
while pwd.count(" ") > 0
    valid = ""
    while valid == ""
        hash = Digest::MD5.hexdigest "#{door_id}#{int}"
        if hash.start_with? start
            # p hash
            valid = hash
        end
        int += 1
    end
    pos = Integer(hash[5], 16)
    if pos >= 0 and pos < 8 and pwd[pos] == " "
        pwd[pos] = valid[6]
        # p pwd
    end
end
p pwd