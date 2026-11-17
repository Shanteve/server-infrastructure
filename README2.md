## Этап 1
Необходимо скачать файл openrc.sh из личного кабинета HostVDS 
Данный файл хранит секретные данные и поэтому его нельзя хранить в Git репозитории.
Для удобства создадим директорию у текущего пользователя, перекинем туда данный файл и установим для него права.
```sh
mkdir -p ~/.config/openstack
mv openrc.sh ~/.config/openstack/hostvds-openrc.sh
chmod 600 ~/.config/openstack/hostvds-openrc.sh
```
После этого активируем окружение
```sh
source ~/.config/openstack/hostvds-openrc.sh
```

## Этап 2