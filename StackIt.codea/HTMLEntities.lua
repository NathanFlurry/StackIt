function HTMLHeader(spacerSize,textSize)
	local textSize = textSize or 30
	local str = [[
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="format-detection" content="telephone=no">
		
		<style>
			body {
				background-color: transparent;
				font-family: 'Futura';
				color: #ffffff;
				text-shadow: 0 2px 10px rgba(0,0,0,100);
				text-align: center;
				padding: 0;
				margin: 0;
			}

			#title {
				font-size: <<titleSize>>px;
				text-align: center;
			}

			#spacer {
				height: <<spacerSize>>px;
			}

			#content {
				font-size: <<textSize>>px; /*30px;*/
			}

			table {
				width: 100%;
				margin-bottom: 75px
			}

			td {
				padding: 5px;
			}

			.leftCell {
				text-align: right;
				width: 50%;
			}

			.rightCell {
				text-align: left;
				width: 50%;
			}

			.highlight {
				font-size: <<highlightedSize>>px;/*75px;*/
				color: rgb(255, 170, 0);
				text-shadow: 0 2px 10px #a46c00;
			}

			#bottomBar {
				position: fixed;
				bottom: 0;
				background-color: rgba(0, 0, 0, 0.25);
				width: <<bottomBarWidth>>px;/*300px;*/
				/*padding: 10px;*/
				border-radius:100px;
				margin-top: 5px;
				margin-bottom: 10px;
				left: 50%;
				margin-left: <<bottomBarMargin>>px;/*-150px;*/
				padding-top: 5px;
				padding-bottom: 5px;
				box-shadow:0px 0px 15px rgba(255,255,255,.1);
			}

			.alignRight {
				text-align: right;
			}

			.alignLeft {
				text-align: left;
			}

			.alignCenter {
				text-align: center;
			}

			hr {
				border: 1px solid #ffffff;
				box-shadow: 0 2px 10px #000000;
				width: 30%;
			}
		</style>
	</head>
	<body>
	]]
	str = string.gsub(str,"<<spacerSize>>",tostring(spacerSize))
	str = string.gsub(str,"<<titleSize>>",tostring(140*gScale))
	str = string.gsub(str,"<<textSize>>",tostring(textSize))
	str = string.gsub(str,"<<highlightedSize>>",tostring(textSize*2))
	local bottomBarWidth = 300
	local suggestedBarWidth = WIDTH*.8
	if bottomBarWidth > suggestedBarWidth then
		bottomBarWidth = suggestedBarWidth
	end
	str = string.gsub(str,"<<bottomBarWidth>>",tostring(bottomBarWidth))
	str = string.gsub(str,"<<bottomBarMargin>>",tostring(-bottomBarWidth/2))
	return str
end

function HTMLFooter()
	local str = [[
	</body>
</html>
	]]

	return str
end

function HTMLPage(spacerSize,title,content)
	local str = HTMLHeader(spacerSize)
	str = str..[[
<div id="spacer"></div>
<div id="title"><<title>></div>
<div id="content">
	]]
	str = str..string.gsub(content,"\n","<br />\n")
	str = str.."</div>"
	str = str..HTMLFooter()

	return string.gsub(str,"<<title>>",title)
end

function HTMLScoreDisplay(content,highlightedItem)
	local str = "<table>"
	for i,v in ipairs(content) do
		if i == highlightedItem then
			str = str.."<tr class='highlight'>"
		else
			str = str.."<tr>"
		end
		str = str.."<td class='leftCell'>#"..i.."</td>"
		str = str.."<td class='rightCell'>"..v.."</td>"
		str = str.."</tr>"
	end
	str = str.."</table>"
	str = str.."<div id='bottomBar'><tr><td class='leftCell'>#"..highlightedItem.."  </td><td class='rightCell'>  "..content[highlightedItem].."</td></tr></table></div>"
	return HTMLPage(0,"",str)
end
