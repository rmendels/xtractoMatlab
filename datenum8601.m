function [dtn,spl,tkc,dbg] = datenum8601(str,tkn)
% Convert ISO 8601 formatted date string (timestamp) to serial date number/s.
%
% (c) 2011-2020 Stephen Cobeldick
%
%%% Syntax:
%  dtn = datenum8601(str)
%  dtn = datenum8601(str,tkn)
%  [dtn,spl,tkc] = datenum8601(...)
%
% Convert an ISO 8601 date string to serial date number/s. By default
% automatically detects all ISO 8601 timestamp/s in the input string,
% or an optional token can be used to restrict timestamp/date detection
% to only one particular ISO 8601 style or date/time notation.
%
% This function offers many ISO 8601 timestamp style options:
% * Date in calendar, ordinal, or week-numbering notation.
% * Basic or extended format.
% * Choice of date-time separator character (one of 'T @_').
% * Full or lower precision (trailing units omitted)
% * Decimal fraction of the trailing unit.
% These style options are explained in the tables below.
%
% Note 0: Timezones are not handled or included in the output.
% Note 1: Out-of-range values are permitted in the input date string.
% Note 2: Unspecified month/date/week/day timestamp values default to one (1).
% Note 3: Unspecified hour/minute/second timestamp values default to zero (0).
% Note 4: Auto-detection mode also parses mixed basic/extended timestamps.
%
%% Examples
%
%%% Using the date+time given by date vector [1999,1,3,15,6,48.0568].
%
% >> datenum8601('1999-01-03 15:06:48.0568') % calendar, extended
% ans = 730123.62972287962
%
% >> datenum8601('1999003T150648.0568') % ordinal, basic
% ans = 730123.62972287962
%
% >> datenum8601('1998W537_150648.0568') % week numbering, basic
%  ans = 730123.62972287962
%
% >> [dtn,spl,tkc] = datenum8601('A19990103B1999-003C1998-W53-7D')
% dtn = [730123;730123;730123]
% spl = {'A','B','C','D'}
% tkc = {'ymd';'*yn';'*YWD'}
%
% >> [dtn,spl] = datenum8601('1999-003T15')
% dtn = 730123.6250
% spl = {'',''}
% tkc = {'*ynTH'}
%
% >> [dtn,spl] = datenum8601('1999-01-03T15','*ymd') % specify match token.
% dtn = 730123.0000
% spl = {'','T15'}
%
% >> datevec(datenum8601('19990103 200012')) % default allows 'T @_' separator.
% ans =
%         1999       1       3      20       0      12
% >> datevec(datenum8601('19990103 200012','_')) % date-time separator char.
% ans =
%         1999       1       3       0       0       0
%         2000      12       1       0       0       0
%
%% ISO 8601 Timestamps
%
% The token consists of one letter for each of the consecutive date/time
% units in the timestamp. The token specifies the date notation (calendar,
% ordinal, or week-numbering) and selects either basic or extended format:
%
%%% Input:
%          | Basic Format             | Extended Format (token prefix '*')
% Date     | Token  | Input Timestamp | Token   | Input Timestamp
% Notation:| <tkn>: | <str> Example:  | <tkn>:  | <str> Example:
% =========|========|=================|=========|===========================
% Calendar |'ymdHMS'|'19990103T150648'|'*ymdHMS'|'1999-01-03T15:06:48'
% ---------|--------|-----------------|---------|---------------------------
% Ordinal  |'ynHMS' |'1999003T150648' |'*ynHMS' |'1999-003T15:06:48'
% ---------|--------|-----------------|---------|---------------------------
% Week     |'YWDHMS'|'1998W537T150648'|'*YWDHMS'|'1998-W53-7T15:06:48'
% ---------|--------|-----------------|---------|---------------------------
%
% Options for reduced precision timestamps, non-standard date-time separator
% character, and the addition of a decimal fraction of the trailing unit:
%
% Omit trailing units (reduced precision), eg:                    | Output as DateVector:
% =========|========|=================|=========|=================|=====================
%          |'ymdH'  |'19990103T15'    |'*ymdH'  |'1999-01-03T15'  |[1999,1,3,15,0,0]
% ---------|--------|-----------------|---------|-----------------|---------------------
%          |'yn'    |'1999003'        |'*yn'    |'1999-003'       |[1999,1,3,0,0,0]
% ---------|--------|-----------------|---------|-----------------|---------------------
% Select the date-time separator character (one of 'T',' ','@','_'), eg:
% =========|========|=================|=========|=================|=====================
%          |'yn_HM' |'1999003_1506'   |'*yn_HM' |'1999-003_15:06' |[1999,1,3,15,6,0]
% ---------|--------|-----------------|---------|-----------------|---------------------
%          |'YWD@H' |'1998W537@15'    |'*YWD@H' |'1998-W53-7@15'  |[1999,1,3,15,0,0]
% ---------|--------|-----------------|---------|-----------------|---------------------
% Decimal fraction of trailing date/time value (digits specify decimal places), eg:
% =========|========|=================|=========|=================|=====================
%          |'ynH3'  |'1999003T15.113' |'*ynH3'  |'1999-003T15.113'|[1999,1,3,15,6,46.80]
% ---------|--------|-----------------|---------|-----------------|---------------------
%          |'YWD4'  |'1998W537.6297'  |'*YWD4'  |'1998-W53-7.6297'|[1999,1,3,15,6,46.08]
% ---------|--------|-----------------|---------|-----------------|---------------------
%          |'Y10'   |'1998.9990019485'|'*Y10'   |'1998.9990019485'|[1999,1,3,15,6,48.06]
% ---------|--------|-----------------|---------|-----------------|---------------------
%
% Note 5: This function does not check for ISO 8601 compliance: user beware!
% Note 6: Date-time separator character must be one of 'T',' ','@','_'.
% Note 7: Date notations cannot be combined: note upper/lower case characters!
%
%% Input and Output Arguments
%
%%% Inputs (*=default):
%  str = DateString, possibly containing one or more ISO 8601 dates/timestamps.
%  tkn = CharVector, optional token to select the required date notation and format.
%      = CharScalar, optional date-time separator character, one of 'T @_'.
%      = none, automagically matches any ISO 8601 timestamps in <str>.
%
%%% Outputs:
%  dtn = NumericVector of Serial Date Numbers, one from each timestamp in input <str>.
%  spl = CellOfStrings, the strings before, between and after the detected timestamps.
%  tkc = CellOfStrings, tokens of the matched timestamps, the same size as <dtn>.
%
% See also DATESTR8601 DATEROUND CLOCK NOW DATENUM DATEVEC DATESTR DATETIME NATSORTFILES

%% Input Wrangling
%
isr = @(szv) numel(szv)==2 && szv(1)==1;
ero = 'It appears that you are using Octave with buggy REGEXP.';
%
% Check if the date string constitutes exactly one row:
assert(ischar(str)&&isr(size(str)),...
	'SC:datenum8601:str:NotCharRowVector',...
	'First input <str> must be a 1xN char.')
%
if nargin<2 || (ischar(tkn)&&isscalar(tkn)&&ismember(tkn,'T @_'))
	if nargin<2
		tkn = '[T @_]';
	end
	% Automagically detect any supported ISO 8601 timestamp style.
	hms = ['(',tkn,'\d{2}(:?\d{2}(:?\d{2})?)?)?'];
	wco = '(\d{4})(-?(\d{4}~|\d{3}~|\d{2}(-?\d{2}~)?|W\d{2}(-?\d~)?))?(\.\d+)?(?(2)|W?)';
	rgx = strrep(wco,'~',hms);
	isY = false;
else % Convert user's token into a regular expression.
	hms = '([T @_]?H(M(S)?)?)?';
	wco = '^(\*?)(Y(W(D~)?)?|y(n~|m(d~)?)?)(\d*)$';
	rgx = strrep(wco,'~',hms);
	assert(ischar(tkn)&&isr(size(tkn)),...
		'SC:datenum8601:tkn:NotCharRowVector',...
		'Second input must be a character row vector.')
	tmp = regexp(tkn,rgx,'once','tokens');
	assert(numel(tmp)>0,...
		'SC:datenum8601:tkn:InvalidToken',...
		'Second input is not a supported token (read the help): ''%s''',tkn)
	assert(numel(tmp)==3,...
		'SC:datenum8601:tkn:BuggyOctaveRegexp',ero)
	rgx = dn8601User(tmp{:});
	isY = strcmp(tmp{2},'Y');
end
%
[tkx,spl] = regexp(str,rgx,'tokens','split');
%
if isempty(tkx) % no date string found
	dtn = [];
	tkc = {};
	dbg = {};
	return
end
%
assert(all(cellfun('length',tkx)==4),...
	'SC:datenum8601:str:BuggyOctaveRegexp',ero)
%
tkx = vertcat(tkx{:});
tky = tkx(:,1); % year
tkf = tkx(:,3); % fraction
isY = isY | strcmp(tkx(:,4),'W');
isE = ~cellfun('isempty',regexp(tkx(:,2),'[-:]','once'));
%
%% Identify DateString Values
%
xgr = '-?(W?)(\d{2})-?(\d*)([T @_]?)(\d{2})?:?(\d{2})?:?(\d{2})?';
%
tkx = regexp(tkx(:,2),xgr,'tokens','once');
tkx(cellfun('isempty',tkx)) = {repmat({''},1,7)};
tkx = vertcat(tkx{:});
tkl = cellfun('length',tkx);
%
% Identify date types:
isW = tkl(:,1)==1; % week-numbering dates.
isO = tkl(:,3)==1 & ~isW; % ordinal dates.
% Concatenate ordinal substrings:
tkx(isO,3) = strcat(tkx(isO,2),tkx(isO,3));
tkx(isO,2) = {'1'};
tkl(isO,3) = 3;
tkl(isO,2) = 0;
%
%% Convert String Values to Numeric
%
yrm = str2double(tky);
dtm = str2double(tkx(:,2:3));
tmm = str2double(tkx(:,5:7));
frc = str2double(tkf);
[idc,idr] = find(diff(isnan([yrm,dtm,tmm,yrm+NaN]),1,2).');
% Default date/time values:
dtm(isnan(dtm)) = 1;
tmm(isnan(tmm)) = 0;
frc(isnan(frc)) = 0;
%
% Convert week-numbering to calendar:
isx = isW | isY;
if any(isx)
	adj = 4+mod(datenummx(yrm(isx),1,1),7);
	dtm(isx,2) = dtm(isx,2)+7*dtm(isx,1)-adj;
	dtm(isx,1) = 1;
end
%
%% Special Fractional Values
%
% Years:
isc = all(~tkl,2) & frc;
if any(isc)
	dye = datenummx(yrm(isc)+1,1,1);
	dyb = datenummx(yrm(isc)+0,1,1);
	dye = dye-(4+mod(dye,7)).*isY(isc);
	dyb = dyb-(4+mod(dyb,7)).*isY(isc);
	frc(isc) = frc(isc) .* (dye-dyb); % (year->days)
	idc(isc) = 3;
end
% Months:
is2 = idc==2;
ism = is2 & ~isW & frc;
if any(ism)
	frc(ism) = frc(ism) .* ... (month->days)
		(datenummx(yrm(ism),dtm(ism,1)+1,dtm(ism,2))...
		-datenummx(yrm(ism),dtm(ism,1)+0,dtm(ism,2)));
	idc(ism) = 3;
end
% Weeks:
isf = is2 & isW & frc;
frc(isf) = frc(isf)*7; % (week->days)
idc(isf) = 3;
%
%% Add Fractional Values
%
cmb = [yrm,dtm,tmm];
idx = sub2ind(size(cmb),idr,idc);
cmb(idx) = cmb(idx)+frc;
%
% Convert out-of-range date vectors to serial date numbers:
dtn = datenummx(cmb) - 31*(cmb(:,2)==0);
%
if nargout>2
	tkc = dn8601Type(isE,isW|isY,tkx(:,4),tkl,cellfun('length',tkf)-1);
	dbg = [tky,tkx,tkf];
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%datenum8601
function rgx = dn8601User(pfx,tkn,dgt)
% Convert the user token to a regular expression.
%
dcf = {'',sprintf('\\.\\d{%s}',dgt)};
wny = {'','W?'};
ise = ~isempty(pfx); % is extended.
isf = ~isempty(dgt); % is fractional value.
isY = strcmp(tkn,'Y'); % is week-numbering year.
spd = '-'; % date separator.
spt = ':'; % time separator.
rpd = strcat(spd(ise),{'W\d{2}','\d','\d{3}','\d{2}','\d{2}'}); % WDnmd
rpt = {'\d{2}',[spt(ise),'\d{2}'],[spt(ise),'\d{2}']}; % HMS
[isd,idd] = ismember(tkn,'WDnmd');
[ist,idt] = ismember(tkn,'HMS');
dts = 'T @_'; % date-time separator.
dtx = [find(ismember(dts,tkn)),1];
rgx = [rpd{idd(isd)},dts(dtx(any(ist))),rpt{idt(ist)}];
rgx = sprintf('(\\d{4})(%s)(%s)(%s)',rgx,dcf{1+isf},wny{1+isY});
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%dn8601User
function tkc = dn8601Type(isE,isU,sep,tkl,dgt)
%
cex = {'';'*'};
cyY = {'y';'Y'};
cWm = {'';'W';'m'};
cDd = {'';'D';'d';'n'};
sep(~tkl(:,4) & any(tkl(:,5:7),2)) = {'T'};
cdg = arrayfun(@(n)sprintf('%d',n),dgt,'uni',0);
cdg(dgt<1) = {''};
fun = @(n,c)c(1+(n>0));
tkc = strcat(cex(1+isE),cyY(1+isU),cWm(1+tkl(:,2)-tkl(:,1)),cDd(1+tkl(:,3)),...
	sep,fun(tkl(:,5),{'';'H'}),fun(tkl(:,6),{'';'M'}),fun(tkl(:,7),{'';'S'}),cdg);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%dn8601Type