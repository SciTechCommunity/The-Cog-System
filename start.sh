COG_TOKEN="MzM4MTcwNDE1Mjc0OTE3ODg4.DF3v1Q.vLQKHIFj7Ue0l693ROB7aMa5bTo"
mix escript.build
rm nohup.out
nohup ./cog COG-TOKEN & disown
clear