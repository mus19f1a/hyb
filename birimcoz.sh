#!/usr/bin
# Bağlı Birim Çözme Modülü
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)


#islem="sdb4"
echo "Çözmek istediğiniz bölüme ait partition bilgisini giriniz."
echo "Bağlı bulunan bölümler:\n\t $(cat /proc/mounts | grep /sd | grep -o 'sd[^,\ ]\+' | awk -vORS=,\  '{print $1}' | sed 's/,\ $/\n/')"
read islem

echo "islenilecek bölüm : ${bold}${islem}${normal}"

# Bölüme ait bağlantı bilgisi alınıyor
bagkon=$(cat /proc/mounts | grep "${islem}" | grep -o '/mnt/[^,\ ]\+')


if [ ! -z "${bagkon}" ] ; then
	echo "${blue}Bilgi:${normal}\tbölüme ait bağlantı noktası : ${bold}${bagkon}${normal}"
	
	if [ ! -z "$(lsof | grep ${bagkon})" ] ; then
		echo "${yellow}UYARI:${normal}\tSeçtiğiniz bölüm kullanılıyor.."
		echo "Bu kısım henüz kodlanmadı"
		# Birimi hangi process'ler kullanıyor listelenecek
		#findmnt -S /dev/sdb4
		exit
	else
		# Birim herhangi bir işlem tarafından kullanılmıyorsa devam
		echo "Bölüm ayrılıyor"
		sudo umount /dev/${islem}
	fi
else
	echo "${red}Hata!${normal}\tBağlantı adresi mevcut değil..!"
	exit
fi

