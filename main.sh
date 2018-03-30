nowdate=$(date +%Y%m%d)

TARGET_SSID="******************"

ROOT_DIR=/Users/krishnabhm/bin/inform_reached
LAST_RUN_FILE=${ROOT_DIR}/lastrun.db
LOG_FILE=${ROOT_DIR}/out.log
REACHED_MESSAGES_FILE=${ROOT_DIR}/reachedmsgs.txt
LOVE_MESSAGES_FILE=${ROOT_DIR}/lovemsgs.txt
EMOTICONS_FILE=${ROOT_DIR}/emoticons.txt

lastruntime=$(cat $LAST_RUN_FILE)

if [ $nowdate -gt $lastruntime ]; then
    echo "Trying to execute at $nowdate" >> $LOG_FILE
    SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
    if [ $? -ne 0 ]; then
        echo "    $nowdate : something went wrong while checking SSID." >> $LOG_FILE
    else
        if  [ "$SSID" == "$TARGET_SSID" ]; then



        	rchdNumLines=$(wc -l < $REACHED_MESSAGES_FILE)
        	rchdRandomLineNumber=$(jot -r 1 1 $rchdNumLines)
        	rchdToSend=$(sed "${rchdRandomLineNumber}q;d" $REACHED_MESSAGES_FILE)

        	loveNumLines=$(wc -l < $LOVE_MESSAGES_FILE)
        	loveRandomLineNumber=$(jot -r 1 1 $loveNumLines)
        	loveToSend=$(sed "${loveRandomLineNumber}q;d" $LOVE_MESSAGES_FILE)

        	emoticonsNumLines=$(wc -l < $EMOTICONS_FILE)
        	emoticonsRandomLineNumber=$(jot -r 1 1 $emoticonsNumLines)
        	emoticonsPicked=$(sed "${emoticonsRandomLineNumber}q;d" $EMOTICONS_FILE)
        	emoticonsRandomOccurences=$(jot -r 1 0 3)
        	emoticonsToSend=$(perl -e "print \" $emoticonsPicked\" x $emoticonsRandomOccurences;")

        	curl -H "Content-Type: application/json" -X POST -d "{\"value1\":\"$rchdToSend\", \"value2\":\"$loveToSend\", \"value3\":\"$emoticonsToSend\"}" https://maker.ifttt.com/trigger/reached_work/with/key/*************** > /dev/null




            if [ $? -eq 0 ]; then
                echo $nowdate > $LAST_RUN_FILE
                echo "    $nowdate : Success" >> $LOG_FILE
            else
                echo "    $nowdate : something went wrong making the GET request." >> $LOG_FILE
            fi
        else
            if [ "$SSID" == "" ]; then
                echo "    $nowdate : Not connected to a named wifi SSID yet." >> $LOG_FILE
            else
                echo "    $nowdate : Not connected to $TARGET_SSID yet. Instead connected to $SSID" >> $LOG_FILE
            fi
        fi
    fi
fi
