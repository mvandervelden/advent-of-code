require 'digest/md5'

door_id = "abbhdwsy"
start = "00000"

pwd = ""
int = 0
for i in 0...8
    valid = ""
    while valid == ""
        hash = Digest::MD5.hexdigest "#{door_id}#{int}"
        if hash.start_with? start
            # p hash
            valid = hash
        end
        int += 1
    end
    pwd += valid[5]
    # p pwd
end
p pwd