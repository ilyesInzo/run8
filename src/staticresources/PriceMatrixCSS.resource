@media only screen and (min-aspect-ratio: 4/3) and (min-width: 48em), only screen and (min-width: 64.0625em){
    div.pm {
        max-width: 1000px;
        margin-left: auto;
        margin-right: auto;
    }
}

.pm .progress {
    height: 20px;
    margin-bottom: 0px;
    overflow: hidden;
    background-color: #f5f5f5;
    border-radius: 4px;
    -webkit-box-shadow: inset 0 1px 2px rgba(0,0,0,.1);
    box-shadow: inset 0 1px 2px rgba(0,0,0,.1);
}

.pm .progress-bar {
    float: left;
    width: 0;
    height: 100%;
    font-size: 12px;
    line-height: 20px;
    color: #fff;
    text-align: center;
    background-color: #337ab7;
    -webkit-box-shadow: inset 0 -1px 0 rgba(0,0,0,.15);
    box-shadow: inset 0 -1px 0 rgba(0,0,0,.15);
    -webkit-transition: width .6s ease;
    -o-transition: width .6s ease;
    transition: width .6s ease;
}

.pm .albea-header {
    background: #337ab7;
    color: white;
    font-size: 16px;
    /*overflow: hidden; causes hover to be hidden form information*/
    -webkit-border-radius: 2px;
    -moz-border-radius: 2px;
    border-radius: 2px;
    margin-bottom: .5rem;
}


.pm .albea-header h3 {
	background-color: #5B9BD5;
    padding-left: 4px;
}

.pm .albea-header h2 {
    padding-left: 4px;
    display: inline-block;
}

.pm .whitefill svg{
    fill: white;
}
/*
.pm .slds-section.slds-is-open svg{
    transform: rotate(90deg);
}

.pm .slds-section .slds-icon_container{
    margin-right: 5px;
}
*/
.pm .uiInput--input .input, .pm .uiInput--input.input, .pm .slds-input{
    min-height: calc(1rem + 2px);
    height: 25px;
}

.uiInput--select.select:not([multiple]), .THIS .uiInput--select .select:not([multiple]), .THIS .uiInput--select .uiPopupTrigger a {
    height: 25px!important;
}

.service-dispensing-tbl .blank td{
	border: none!important;
	padding-bottom: 10px;
}

.service-dispensing-tbl .phrase{
	color: red;
	font-size: 12px;
    border: none!important;
    text-align:left!important;
}

.service-dispensing-tbl .first-col{
	background-color: #E2EFDA;
	width:30%;
}

.service-dispensing-tbl .sec-col{
	width:12%;
}

.service-dispensing-tbl .third-col{
	width:12%;
}

.service-dispensing-tbl .last-col{
	background-color: #F2F2F2;
	width:30%; 
}
.service-dispensing-tbl th{
	background-color: #808080;
	color: white;
	padding-left: 4px;
	border: 1px solid #808080;
}

.service-dispensing-tbl td{
	border: 1px solid #808080;
	text-align: center;
}
.Recap-header {
    background-color: rgba(0, 68, 135, 1);
    color: white;
    font-weight: bold;
    border: 1px solid #808080;
	text-align: center;
    /*overflow: hidden; causes hover to be hidden form information*/
    -webkit-border-radius: 0.25rem;
    -moz-border-radius:0.25rem;
    border-radius: 2px;
    margin:1px 0px;
    min-height: 100% !important;
    width: 100%;
    hyphens: none;
}
.Recap-Line{
    min-height: calc(1rem + 2px);
    height:25px;
    margin:1px 0px;
    display: block;
    padding-top: 0;
    padding-right: var(--sds-c-input-spacing-horizontal-end, var(--lwc-spacingMedium,1rem));
    padding-bottom: 0;
    padding-left: var(--sds-c-input-spacing-horizontal-start, var(--lwc-spacingSmall,0.75rem));
    width: 100%;
    border: var(--lwc-borderWidthThin,1px) solid var(--sds-c-input-color-border, var(--lwc-colorBorderInput,rgb(221, 219, 218)));
    border-radius: var(--sds-c-input-radius-border, var(--lwc-borderRadiusMedium,0.25rem));
    background-color: var(--sds-c-input-color-background, var(--lwc-colorBackgroundInput,rgb(255, 255, 255)));
    color: var(--sds-c-input-text-color);
    box-shadow: var(--sds-c-input-shadow);
    transition: border var(--lwc-durationQuickly,0.1s) linear,background-color var(--lwc-durationQuickly,0.1s) linear;
}
.Recap-Edit-Line{
    height:25px;
    margin:1px 0px;
}
.Recap-Section-Header{
    padding:0.5rem;background-color:#f4f6f9;height:50px                                                                
}
.Recap-Table-Container{width:50%;margin:20px;}
.Recap-Div-Rowspan{position:absolute;top: 0px;left: 0px;right: 0px; bottom: 0px;text-align:center}