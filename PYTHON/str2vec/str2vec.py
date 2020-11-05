msg_str = "Hello World!\n"

print("(")
for ch in msg_str:
    print("\""+'{0:08b}'.format(ord(ch))+"\""+",")
print(");")
