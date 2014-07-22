sudo killall python
sudo service memcached restart
python main.py >> log.log &> err.log &
