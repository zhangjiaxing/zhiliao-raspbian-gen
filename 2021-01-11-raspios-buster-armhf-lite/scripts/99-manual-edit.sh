
echo
echo
echo
echo "[npm run enable]"
#echo "manual edit :"
echo -en "是否进入自定义shell[y/n]: "
read yorn
if [[ "$yorn" == "Y" || "$yorn" == "y" ]];then
    echo "已经进入用来自定义镜像的临时shell."
    echo "完成自定义操作后，输入Ctrl+D 或 exit 完成."
    (
        export PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\[\e[1;31m\][SubShell]\[\e[;m\]\$ "
        bash
    )
fi

echo "已经退出临时shell."

