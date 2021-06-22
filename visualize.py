
#%%
import pandas as  pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

cfg = np.loadtxt("data/cfg.txt")

handler = np.loadtxt('data/naive_conway.txt')
handler2 = np.loadtxt("data/texture_conway.txt")
def save_anim(h,num):
    mD = handler.reshape(int(cfg[0]+1),int(cfg[1]),int(cfg[2]))
    fig = plt.figure(figsize=(10,10))
    plt.title("Conway", fontsize = 20)
    im = plt.imshow(mD[0])
    plt.show()
  
    def animate(i):
        im.set_array(mD[i])
        return [im]

    anim = animation.FuncAnimation(fig,animate,frames = int(cfg[0]+1) ,interval = 100 )
    anim.save("vids/Cw_game_"+str(num)+ ".gif",writer='pillow')
    
save_anim(handler,1)
save_anim(handler2,2)
# %%