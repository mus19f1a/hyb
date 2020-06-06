#!/usr/bin
# Birim Bağlama Modülü
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 6)

#islem="sdb4"
echo "Bağlamak istediğiniz bölüme ait partition bilgisini giriniz:"
echo "Bulunan bölümler:\n\t $(lsblk | grep part | grep -o 'sd[^,\ ]\+' | awk -vORS=,\  '{print $1}' | sed 's/,\ $/\n/')"
read islem

echo "islenilecek bölüm : ${bold}${islem}${normal}"

if [ -z "$(lsblk | grep "${islem}\ ")" ]; then
	echo "${bold}${red}Hata!${normal}\tBöyle bir bölüm bulunamadı..."
	echo "\t\"${bold}${islem}${normal}\" mevcut değil."
	exit
fi


# Bölüme ait etiket bilgisi alınıyor
bagkon=$(sudo e2label /dev/$islem)


if [ -z "$bagkon" ]; then
	echo "${cyan}Uyarı!${normal} Bölüme ait etiket mevcut değil."
	echo "yeni bir etiket oluşturulsun mu? (E/h)"
	read cevap
	
	if [ ${cevap} == 'E' or ${cevap} == '']; then

		echo "Etiket bilgisini giriniz.. (ab..zAB..Z012..9 only)"
		read etiket
		echo "bu özellik doğrulanmadığından bu sürümde devredışıdır"
		echo "etiket bilginiz geçici olarak tutulacaktır "
		#echo "Bölüme için etiket oluşturuluyor"
		#tune2fs -L ${etiket} /dev/sdb2 
		bagkon=$( echo "${etiket}" | sed $'s/[^[:alnum:]\t]//g')
	else
		echo "${bold}${red}Hata!${normal}\tEtiket olmadan devam edemiyoruz."
		echo "Sonraki sürümlerde bu eksiklik giderilecektir."
		exit
	fi
else
	echo "bölüme ait etiket bilgisi : ${bold}${bagkon}${normal}"
fi


if [ ! -d "/mnt" ]; then
	echo "${bold}${red}Hata!${normal}\tKök dizininde \"mnt\" yer almadığından işleminize devam edemiyoruz.."
	exit
elif [ ! -d "/mnt/${bagkon}/" ]; then
	echo "Bağlantı konumu oluşturuluyor"
	sudo mkdir /mnt/${bagkon}
else
	echo "${blue}Bilgi:${normal}\tBağlantı dizini zaten mevcut"
	# dizine herhangi bir birim bağlı değilse devam
	if [ ! -z "$(cat /proc/mounts | grep "/mnt/${bagkon}")" ]; then
		echo "Dizine bağlantı yapılmış\n${bold}${islem}${normal} bölümü ayrılıyor"
		sudo umount /dev/${islem}

	elif [ ! -z "$(cat /proc/mounts | grep "/dev/${islem} /mnt/${bagkon}/")" ]; then
		echo "${blue}Bilgi:${normal}\tBu birim zaten bağlanmış!"
		# eklemeler yapılacak
		# dizin yetkileri doğru mu?
		exit
	fi
fi


if [ ! -z "$(cat /proc/mounts | grep ${islem})" ]; then
	echo "${yellow}UYARI:${normal}\tSeçtiğiniz bölüm kullanılıyor.."
	echo "Bu kısım henüz kodlanmadı"
	# Birimi hangi process kullanıyor
	#findmnt -S /dev/sdb4
	
	exit
else
	echo "Birim bağlanılıyor"
	if [ ! -z "$(findmnt -S "/dev/${islem}")" ]; then
		echo "${blue}Bilgi!${normal}\tBu birim zaten farklı bir noktaya bağlanmış..!"
		echo "biri çözülüp varsayılan noktaya bağlansın mı? (E/h)"
		read cevap
		
		if [ ${cevap} == 'E' or ${cevap} == '']; then
			echo "Bölüm ayrılıyor"
			sudo umount /dev/${islem}
			echo "Bölüme varsayılan noktaya bağlanıyor"
			sudo mount /dev/${islem} /mnt/${bagkon}/
		else
			exit
		fi
	else
		sudo mount /dev/${islem} /mnt/${bagkon}/
	fi
fi 



