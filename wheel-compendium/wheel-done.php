<?php
function fetchCompendiumPage($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if ($httpCode == 200) {
        return $response;
    } else {
        throw new Exception('Failed to load web page');
    }
}

function parseTableData($htmlContent) {
    $dom = new DOMDocument;
    @$dom->loadHTML($htmlContent);
    $xpath = new DOMXPath($dom);

    $error = $xpath->query('//div[@class="container error"]');
    if ($error->length > 0) {
        return null;
    }

    $table = $xpath->query('//div[@id="zone_2"]//table');
    if ($table->length == 0) {
        return [];
    }

    $rows = $table->item(0)->getElementsByTagName('tr');
    $tableData = [];

    foreach ($rows as $row) {
        $cells = $row->getElementsByTagName('td');
        if ($cells->length >= 2) {
            /*$rowData = [
                'puzzle' => trim($cells->item(0)->textContent),
                'category' => trim($cells->item(1)->textContent),
            ];*/
            //$tableData[] = $rowData;
            $tableData[] = trim($cells->item(0)->textContent);
            $tableData[] = "\n";
        }
    }
    return $tableData;
}

function iterateCompendium() {
    $wheelOfFortuneSeason = 1;
    $looping = true;
    $stopwatch = microtime(true);

    while ($looping && $wheelOfFortuneSeason < 41) {
        try {
            echo "Processing page $wheelOfFortuneSeason\n";

            $buyAVowelPage = fetchCompendiumPage("https://buyavowel.boards.net/page/compendium$wheelOfFortuneSeason");
            $buyAVowelPageData = parseTableData($buyAVowelPage);

            if (!is_null($buyAVowelPageData)) {
                
                // Write data to disk
                $stringToWrite = implode("\n", $buyAVowelPageData);

                // Write the string to a text file
                file_put_contents("data_season_$wheelOfFortuneSeason.txt", $buyAVowelPageData);
                //file_put_contents("data_season_$wheelOfFortuneSeason.json", json_encode($buyAVowelPageData));
                $wheelOfFortuneSeason++;
            } else {
                $looping = false;
            }
        } catch (Exception $e) {
            echo "Error: " . $e->getMessage() . "\n";
            $looping = false;
        }
    }

    $stopwatch = microtime(true) - $stopwatch;
    echo "Last page processed in $stopwatch seconds\n";
}

iterateCompendium();
?>
