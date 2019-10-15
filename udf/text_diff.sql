CREATE OR REPLACE FUNCTION udf.text_diff(text1 STRING, text2 STRING, options_json STRING)
RETURNS STRUCT<
    diffs STRING,
    patches STRING,
    html STRING,
    distance INT64,
    gnu_patch STRING
>
LANGUAGE js
AS
"""var rollup=function(){\"use strict\";return function(t,e){return t(e={exports:{}},e.exports),e.exports}((function(t){function e(){this.Diff_Timeout=1,this.Diff_EditCost=4,this.Match_Threshold=.5,this.Match_Distance=1e3,this.Patch_DeleteThreshold=.5,this.Patch_Margin=4,this.Match_MaxBits=32}e.prototype.diff_main=function(t,e,n,r){void 0===r&&(r=this.Diff_Timeout<=0?Number.MAX_VALUE:(new Date).getTime()+1e3*this.Diff_Timeout);var i=r;if(null==t||null==e)throw new Error(\"Null input. (diff_main)\");if(t==e)return t?[[0,t]]:[];void 0===n&&(n=!0);var s=n,h=this.diff_commonPrefix(t,e),a=t.substring(0,h);t=t.substring(h),e=e.substring(h),h=this.diff_commonSuffix(t,e);var f=t.substring(t.length-h);t=t.substring(0,t.length-h),e=e.substring(0,e.length-h);var l=this.diff_compute_(t,e,s,i);return a&&l.unshift([0,a]),f&&l.push([0,f]),this.diff_cleanupMerge(l),l},e.prototype.diff_compute_=function(t,e,n,r){var i;if(!t)return[[1,e]];if(!e)return[[-1,t]];var s=t.length>e.length?t:e,h=t.length>e.length?e:t,a=s.indexOf(h);if(-1!=a)return i=[[1,s.substring(0,a)],[0,h],[1,s.substring(a+h.length)]],t.length>e.length&&(i[0][0]=i[2][0]=-1),i;if(1==h.length)return[[-1,t],[1,e]];var f=this.diff_halfMatch_(t,e);if(f){var l=f[0],g=f[1],o=f[2],c=f[3],u=f[4],p=this.diff_main(l,o,n,r),d=this.diff_main(g,c,n,r);return p.concat([[0,u]],d)}return n&&t.length>100&&e.length>100?this.diff_lineMode_(t,e,r):this.diff_bisect_(t,e,r)},e.prototype.diff_lineMode_=function(t,e,n){t=(g=this.diff_linesToChars_(t,e)).chars1,e=g.chars2;var r=g.lineArray,i=this.diff_main(t,e,!1,n);this.diff_charsToLines_(i,r),this.diff_cleanupSemantic(i),i.push([0,\"\"]);for(var s=0,h=0,a=0,f=\"\",l=\"\";s<i.length;){switch(i[s][0]){case 1:a++,l+=i[s][1];break;case-1:h++,f+=i[s][1];break;case 0:if(h>=1&&a>=1){i.splice(s-h-a,h+a),s=s-h-a;for(var g,o=(g=this.diff_main(f,l,!1,n)).length-1;o>=0;o--)i.splice(s,0,g[o]);s+=g.length}a=0,h=0,f=\"\",l=\"\"}s++}return i.pop(),i},e.prototype.diff_bisect_=function(t,e,n){for(var r=t.length,i=e.length,s=Math.ceil((r+i)/2),h=s,a=2*s,f=new Array(a),l=new Array(a),g=0;g<a;g++)f[g]=-1,l[g]=-1;f[h+1]=0,l[h+1]=0;for(var o=r-i,c=o%2!=0,u=0,p=0,d=0,_=0,b=0;b<s&&!((new Date).getTime()>n);b++){for(var v=-b+u;v<=b-p;v+=2){for(var m=h+v,x=(k=v==-b||v!=b&&f[m-1]<f[m+1]?f[m+1]:f[m-1]+1)-v;k<r&&x<i&&t.charAt(k)==e.charAt(x);)k++,x++;if(f[m]=k,k>r)p+=2;else if(x>i)u+=2;else if(c){if((w=h+o-v)>=0&&w<a&&-1!=l[w])if(k>=(y=r-l[w]))return this.diff_bisectSplit_(t,e,k,x,n)}}for(var M=-b+d;M<=b-_;M+=2){for(var y,w=h+M,A=(y=M==-b||M!=b&&l[w-1]<l[w+1]?l[w+1]:l[w-1]+1)-M;y<r&&A<i&&t.charAt(r-y-1)==e.charAt(i-A-1);)y++,A++;if(l[w]=y,y>r)_+=2;else if(A>i)d+=2;else if(!c){if((m=h+o-M)>=0&&m<a&&-1!=f[m]){var k;x=h+(k=f[m])-m;if(k>=(y=r-y))return this.diff_bisectSplit_(t,e,k,x,n)}}}}return[[-1,t],[1,e]]},e.prototype.diff_bisectSplit_=function(t,e,n,r,i){var s=t.substring(0,n),h=e.substring(0,r),a=t.substring(n),f=e.substring(r),l=this.diff_main(s,h,!1,i),g=this.diff_main(a,f,!1,i);return l.concat(g)},e.prototype.diff_linesToChars_=function(t,e){var n=[],r={};function i(t){for(var e=\"\",i=0,s=-1,h=n.length;s<t.length-1;){-1==(s=t.indexOf(\"\\n\",i))&&(s=t.length-1);var a=t.substring(i,s+1);i=s+1,(r.hasOwnProperty?r.hasOwnProperty(a):void 0!==r[a])?e+=String.fromCharCode(r[a]):(e+=String.fromCharCode(h),r[a]=h,n[h++]=a)}return e}return n[0]=\"\",{chars1:i(t),chars2:i(e),lineArray:n}},e.prototype.diff_charsToLines_=function(t,e){for(var n=0;n<t.length;n++){for(var r=t[n][1],i=[],s=0;s<r.length;s++)i[s]=e[r.charCodeAt(s)];t[n][1]=i.join(\"\")}},e.prototype.diff_commonPrefix=function(t,e){if(!t||!e||t.charAt(0)!=e.charAt(0))return 0;for(var n=0,r=Math.min(t.length,e.length),i=r,s=0;n<i;)t.substring(s,i)==e.substring(s,i)?s=n=i:r=i,i=Math.floor((r-n)/2+n);return i},e.prototype.diff_commonSuffix=function(t,e){if(!t||!e||t.charAt(t.length-1)!=e.charAt(e.length-1))return 0;for(var n=0,r=Math.min(t.length,e.length),i=r,s=0;n<i;)t.substring(t.length-i,t.length-s)==e.substring(e.length-i,e.length-s)?s=n=i:r=i,i=Math.floor((r-n)/2+n);return i},e.prototype.diff_commonOverlap_=function(t,e){var n=t.length,r=e.length;if(0==n||0==r)return 0;n>r?t=t.substring(n-r):n<r&&(e=e.substring(0,n));var i=Math.min(n,r);if(t==e)return i;for(var s=0,h=1;;){var a=t.substring(i-h),f=e.indexOf(a);if(-1==f)return s;h+=f,0!=f&&t.substring(i-h)!=e.substring(0,h)||(s=h,h++)}},e.prototype.diff_halfMatch_=function(t,e){if(this.Diff_Timeout<=0)return null;var n=t.length>e.length?t:e,r=t.length>e.length?e:t;if(n.length<4||2*r.length<n.length)return null;var i=this;function s(t,e,n){for(var r,s,h,a,f=t.substring(n,n+Math.floor(t.length/4)),l=-1,g=\"\";-1!=(l=e.indexOf(f,l+1));){var o=i.diff_commonPrefix(t.substring(n),e.substring(l)),c=i.diff_commonSuffix(t.substring(0,n),e.substring(0,l));g.length<c+o&&(g=e.substring(l-c,l)+e.substring(l,l+o),r=t.substring(0,n-c),s=t.substring(n+o),h=e.substring(0,l-c),a=e.substring(l+o))}return 2*g.length>=t.length?[r,s,h,a,g]:null}var h,a,f,l,g,o=s(n,r,Math.ceil(n.length/4)),c=s(n,r,Math.ceil(n.length/2));return o||c?(h=c?o&&o[4].length>c[4].length?o:c:o,t.length>e.length?(a=h[0],f=h[1],l=h[2],g=h[3]):(l=h[0],g=h[1],a=h[2],f=h[3]),[a,f,l,g,h[4]]):null},e.prototype.diff_cleanupSemantic=function(t){for(var e=!1,n=[],r=0,i=null,s=0,h=0,a=0,f=0,l=0;s<t.length;)0==t[s][0]?(n[r++]=s,h=f,a=l,f=0,l=0,i=t[s][1]):(1==t[s][0]?f+=t[s][1].length:l+=t[s][1].length,i&&i.length<=Math.max(h,a)&&i.length<=Math.max(f,l)&&(t.splice(n[r-1],0,[-1,i]),t[n[r-1]+1][0]=1,r--,s=--r>0?n[r-1]:-1,h=0,a=0,f=0,l=0,i=null,e=!0)),s++;for(e&&this.diff_cleanupMerge(t),this.diff_cleanupSemanticLossless(t),s=1;s<t.length;){if(-1==t[s-1][0]&&1==t[s][0]){var g=t[s-1][1],o=t[s][1],c=this.diff_commonOverlap_(g,o),u=this.diff_commonOverlap_(o,g);c>=u?(c>=g.length/2||c>=o.length/2)&&(t.splice(s,0,[0,o.substring(0,c)]),t[s-1][1]=g.substring(0,g.length-c),t[s+1][1]=o.substring(c),s++):(u>=g.length/2||u>=o.length/2)&&(t.splice(s,0,[0,g.substring(0,u)]),t[s-1][0]=1,t[s-1][1]=o.substring(0,o.length-u),t[s+1][0]=-1,t[s+1][1]=g.substring(u),s++),s++}s++}},e.prototype.diff_cleanupSemanticLossless=function(t){function n(t,n){if(!t||!n)return 6;var r=t.charAt(t.length-1),i=n.charAt(0),s=r.match(e.nonAlphaNumericRegex_),h=i.match(e.nonAlphaNumericRegex_),a=s&&r.match(e.whitespaceRegex_),f=h&&i.match(e.whitespaceRegex_),l=a&&r.match(e.linebreakRegex_),g=f&&i.match(e.linebreakRegex_),o=l&&t.match(e.blanklineEndRegex_),c=g&&n.match(e.blanklineStartRegex_);return o||c?5:l||g?4:s&&!a&&f?3:a||f?2:s||h?1:0}for(var r=1;r<t.length-1;){if(0==t[r-1][0]&&0==t[r+1][0]){var i=t[r-1][1],s=t[r][1],h=t[r+1][1],a=this.diff_commonSuffix(i,s);if(a){var f=s.substring(s.length-a);i=i.substring(0,i.length-a),s=f+s.substring(0,s.length-a),h=f+h}for(var l=i,g=s,o=h,c=n(i,s)+n(s,h);s.charAt(0)===h.charAt(0);){i+=s.charAt(0),s=s.substring(1)+h.charAt(0),h=h.substring(1);var u=n(i,s)+n(s,h);u>=c&&(c=u,l=i,g=s,o=h)}t[r-1][1]!=l&&(l?t[r-1][1]=l:(t.splice(r-1,1),r--),t[r][1]=g,o?t[r+1][1]=o:(t.splice(r+1,1),r--))}r++}},e.nonAlphaNumericRegex_=/[^a-zA-Z0-9]/,e.whitespaceRegex_=/\\s/,e.linebreakRegex_=/[\\r\\n]/,e.blanklineEndRegex_=/\\n\\r?\\n$/,e.blanklineStartRegex_=/^\\r?\\n\\r?\\n/,e.prototype.diff_cleanupEfficiency=function(t){for(var e=!1,n=[],r=0,i=null,s=0,h=!1,a=!1,f=!1,l=!1;s<t.length;)0==t[s][0]?(t[s][1].length<this.Diff_EditCost&&(f||l)?(n[r++]=s,h=f,a=l,i=t[s][1]):(r=0,i=null),f=l=!1):(-1==t[s][0]?l=!0:f=!0,i&&(h&&a&&f&&l||i.length<this.Diff_EditCost/2&&h+a+f+l==3)&&(t.splice(n[r-1],0,[-1,i]),t[n[r-1]+1][0]=1,r--,i=null,h&&a?(f=l=!0,r=0):(s=--r>0?n[r-1]:-1,f=l=!1),e=!0)),s++;e&&this.diff_cleanupMerge(t)},e.prototype.diff_cleanupMerge=function(t){t.push([0,\"\"]);for(var e,n=0,r=0,i=0,s=\"\",h=\"\";n<t.length;)switch(t[n][0]){case 1:i++,h+=t[n][1],n++;break;case-1:r++,s+=t[n][1],n++;break;case 0:r+i>1?(0!==r&&0!==i&&(0!==(e=this.diff_commonPrefix(h,s))&&(n-r-i>0&&0==t[n-r-i-1][0]?t[n-r-i-1][1]+=h.substring(0,e):(t.splice(0,0,[0,h.substring(0,e)]),n++),h=h.substring(e),s=s.substring(e)),0!==(e=this.diff_commonSuffix(h,s))&&(t[n][1]=h.substring(h.length-e)+t[n][1],h=h.substring(0,h.length-e),s=s.substring(0,s.length-e))),0===r?t.splice(n-i,r+i,[1,h]):0===i?t.splice(n-r,r+i,[-1,s]):t.splice(n-r-i,r+i,[-1,s],[1,h]),n=n-r-i+(r?1:0)+(i?1:0)+1):0!==n&&0==t[n-1][0]?(t[n-1][1]+=t[n][1],t.splice(n,1)):n++,i=0,r=0,s=\"\",h=\"\"}\"\"===t[t.length-1][1]&&t.pop();var a=!1;for(n=1;n<t.length-1;)0==t[n-1][0]&&0==t[n+1][0]&&(t[n][1].substring(t[n][1].length-t[n-1][1].length)==t[n-1][1]?(t[n][1]=t[n-1][1]+t[n][1].substring(0,t[n][1].length-t[n-1][1].length),t[n+1][1]=t[n-1][1]+t[n+1][1],t.splice(n-1,1),a=!0):t[n][1].substring(0,t[n+1][1].length)==t[n+1][1]&&(t[n-1][1]+=t[n+1][1],t[n][1]=t[n][1].substring(t[n+1][1].length)+t[n+1][1],t.splice(n+1,1),a=!0)),n++;a&&this.diff_cleanupMerge(t)},e.prototype.diff_xIndex=function(t,e){var n,r=0,i=0,s=0,h=0;for(n=0;n<t.length&&(1!==t[n][0]&&(r+=t[n][1].length),-1!==t[n][0]&&(i+=t[n][1].length),!(r>e));n++)s=r,h=i;return t.length!=n&&-1===t[n][0]?h:h+(e-s)},e.prototype.diff_prettyHtml=function(t){for(var e=[],n=/&/g,r=/</g,i=/>/g,s=/\\n/g,h=0;h<t.length;h++){var a=t[h][0],f=t[h][1].replace(n,\"&amp;\").replace(r,\"&lt;\").replace(i,\"&gt;\").replace(s,\"&para;<br>\");switch(a){case 1:e[h]='<ins style=\"background:#e6ffe6;\">'+f+\"</ins>\";break;case-1:e[h]='<del style=\"background:#ffe6e6;\">'+f+\"</del>\";break;case 0:e[h]=\"<span>\"+f+\"</span>\"}}return e.join(\"\")},e.prototype.diff_text1=function(t){for(var e=[],n=0;n<t.length;n++)1!==t[n][0]&&(e[n]=t[n][1]);return e.join(\"\")},e.prototype.diff_text2=function(t){for(var e=[],n=0;n<t.length;n++)-1!==t[n][0]&&(e[n]=t[n][1]);return e.join(\"\")},e.prototype.diff_levenshtein=function(t){for(var e=0,n=0,r=0,i=0;i<t.length;i++){var s=t[i][0],h=t[i][1];switch(s){case 1:n+=h.length;break;case-1:r+=h.length;break;case 0:e+=Math.max(n,r),n=0,r=0}}return e+=Math.max(n,r)},e.prototype.diff_toDelta=function(t){for(var e=[],n=0;n<t.length;n++)switch(t[n][0]){case 1:e[n]=\"+\"+encodeURI(t[n][1]);break;case-1:e[n]=\"-\"+t[n][1].length;break;case 0:e[n]=\"=\"+t[n][1].length}return e.join(\"\\t\").replace(/%20/g,\" \")},e.prototype.diff_fromDelta=function(t,e){for(var n=[],r=0,i=0,s=e.split(/\\t/g),h=0;h<s.length;h++){var a=s[h].substring(1);switch(s[h].charAt(0)){case\"+\":try{n[r++]=[1,decodeURI(a)]}catch(t){throw new Error(\"Illegal escape in diff_fromDelta: \"+a)}break;case\"-\":case\"=\":var f=parseInt(a,10);if(isNaN(f)||f<0)throw new Error(\"Invalid number in diff_fromDelta: \"+a);var l=t.substring(i,i+=f);\"=\"==s[h].charAt(0)?n[r++]=[0,l]:n[r++]=[-1,l];break;default:if(s[h])throw new Error(\"Invalid diff operation in diff_fromDelta: \"+s[h])}}if(i!=t.length)throw new Error(\"Delta length (\"+i+\") does not equal source text length (\"+t.length+\").\");return n},e.prototype.match_main=function(t,e,n){if(null==t||null==e||null==n)throw new Error(\"Null input. (match_main)\");return n=Math.max(0,Math.min(n,t.length)),t==e?0:t.length?t.substring(n,n+e.length)==e?n:this.match_bitap_(t,e,n):-1},e.prototype.match_bitap_=function(t,e,n){if(e.length>this.Match_MaxBits)throw new Error(\"Pattern too long for this browser.\");var r=this.match_alphabet_(e),i=this;function s(t,r){var s=t/e.length,h=Math.abs(n-r);return i.Match_Distance?s+h/i.Match_Distance:h?1:s}var h=this.Match_Threshold,a=t.indexOf(e,n);-1!=a&&(h=Math.min(s(0,a),h),-1!=(a=t.lastIndexOf(e,n+e.length))&&(h=Math.min(s(0,a),h)));var f,l,g=1<<e.length-1;a=-1;for(var o,c=e.length+t.length,u=0;u<e.length;u++){for(f=0,l=c;f<l;)s(u,n+l)<=h?f=l:c=l,l=Math.floor((c-f)/2+f);c=l;var p=Math.max(1,n-l+1),d=Math.min(n+l,t.length)+e.length,_=Array(d+2);_[d+1]=(1<<u)-1;for(var b=d;b>=p;b--){var v=r[t.charAt(b-1)];if(_[b]=0===u?(_[b+1]<<1|1)&v:(_[b+1]<<1|1)&v|(o[b+1]|o[b])<<1|1|o[b+1],_[b]&g){var m=s(u,b-1);if(m<=h){if(h=m,!((a=b-1)>n))break;p=Math.max(1,2*n-a)}}}if(s(u+1,n)>h)break;o=_}return a},e.prototype.match_alphabet_=function(t){for(var e={},n=0;n<t.length;n++)e[t.charAt(n)]=0;for(n=0;n<t.length;n++)e[t.charAt(n)]|=1<<t.length-n-1;return e},e.prototype.patch_addContext_=function(t,e){if(0!=e.length){for(var n=e.substring(t.start2,t.start2+t.length1),r=0;e.indexOf(n)!=e.lastIndexOf(n)&&n.length<this.Match_MaxBits-this.Patch_Margin-this.Patch_Margin;)r+=this.Patch_Margin,n=e.substring(t.start2-r,t.start2+t.length1+r);r+=this.Patch_Margin;var i=e.substring(t.start2-r,t.start2);i&&t.diffs.unshift([0,i]);var s=e.substring(t.start2+t.length1,t.start2+t.length1+r);s&&t.diffs.push([0,s]),t.start1-=i.length,t.start2-=i.length,t.length1+=i.length+s.length,t.length2+=i.length+s.length}},e.prototype.patch_make=function(t,n,r){var i,s;if(\"string\"==typeof t&&\"string\"==typeof n&&void 0===r)i=t,(s=this.diff_main(i,n,!0)).length>2&&(this.diff_cleanupSemantic(s),this.diff_cleanupEfficiency(s));else if(t&&\"object\"==typeof t&&void 0===n&&void 0===r)s=t,i=this.diff_text1(s);else if(\"string\"==typeof t&&n&&\"object\"==typeof n&&void 0===r)i=t,s=n;else{if(\"string\"!=typeof t||\"string\"!=typeof n||!r||\"object\"!=typeof r)throw new Error(\"Unknown call format to patch_make.\");i=t,s=r}if(0===s.length)return[];for(var h=[],a=new e.patch_obj,f=0,l=0,g=0,o=i,c=i,u=0;u<s.length;u++){var p=s[u][0],d=s[u][1];switch(f||0===p||(a.start1=l,a.start2=g),p){case 1:a.diffs[f++]=s[u],a.length2+=d.length,c=c.substring(0,g)+d+c.substring(g);break;case-1:a.length1+=d.length,a.diffs[f++]=s[u],c=c.substring(0,g)+c.substring(g+d.length);break;case 0:d.length<=2*this.Patch_Margin&&f&&s.length!=u+1?(a.diffs[f++]=s[u],a.length1+=d.length,a.length2+=d.length):d.length>=2*this.Patch_Margin&&f&&(this.patch_addContext_(a,o),h.push(a),a=new e.patch_obj,f=0,o=c,l=g)}1!==p&&(l+=d.length),-1!==p&&(g+=d.length)}return f&&(this.patch_addContext_(a,o),h.push(a)),h},e.prototype.patch_deepCopy=function(t){for(var n=[],r=0;r<t.length;r++){var i=t[r],s=new e.patch_obj;s.diffs=[];for(var h=0;h<i.diffs.length;h++)s.diffs[h]=i.diffs[h].slice();s.start1=i.start1,s.start2=i.start2,s.length1=i.length1,s.length2=i.length2,n[r]=s}return n},e.prototype.patch_apply=function(t,e){if(0==t.length)return[e,[]];t=this.patch_deepCopy(t);var n=this.patch_addPadding(t);e=n+e+n,this.patch_splitMax(t);for(var r=0,i=[],s=0;s<t.length;s++){var h,a,f=t[s].start2+r,l=this.diff_text1(t[s].diffs),g=-1;if(l.length>this.Match_MaxBits?-1!=(h=this.match_main(e,l.substring(0,this.Match_MaxBits),f))&&(-1==(g=this.match_main(e,l.substring(l.length-this.Match_MaxBits),f+l.length-this.Match_MaxBits))||h>=g)&&(h=-1):h=this.match_main(e,l,f),-1==h)i[s]=!1,r-=t[s].length2-t[s].length1;else if(i[s]=!0,r=h-f,l==(a=-1==g?e.substring(h,h+l.length):e.substring(h,g+this.Match_MaxBits)))e=e.substring(0,h)+this.diff_text2(t[s].diffs)+e.substring(h+l.length);else{var o=this.diff_main(l,a,!1);if(l.length>this.Match_MaxBits&&this.diff_levenshtein(o)/l.length>this.Patch_DeleteThreshold)i[s]=!1;else{this.diff_cleanupSemanticLossless(o);for(var c,u=0,p=0;p<t[s].diffs.length;p++){var d=t[s].diffs[p];0!==d[0]&&(c=this.diff_xIndex(o,u)),1===d[0]?e=e.substring(0,h+c)+d[1]+e.substring(h+c):-1===d[0]&&(e=e.substring(0,h+c)+e.substring(h+this.diff_xIndex(o,u+d[1].length))),-1!==d[0]&&(u+=d[1].length)}}}}return[e=e.substring(n.length,e.length-n.length),i]},e.prototype.patch_addPadding=function(t){for(var e=this.Patch_Margin,n=\"\",r=1;r<=e;r++)n+=String.fromCharCode(r);for(r=0;r<t.length;r++)t[r].start1+=e,t[r].start2+=e;var i=t[0],s=i.diffs;if(0==s.length||0!=s[0][0])s.unshift([0,n]),i.start1-=e,i.start2-=e,i.length1+=e,i.length2+=e;else if(e>s[0][1].length){var h=e-s[0][1].length;s[0][1]=n.substring(s[0][1].length)+s[0][1],i.start1-=h,i.start2-=h,i.length1+=h,i.length2+=h}if(0==(s=(i=t[t.length-1]).diffs).length||0!=s[s.length-1][0])s.push([0,n]),i.length1+=e,i.length2+=e;else if(e>s[s.length-1][1].length){h=e-s[s.length-1][1].length;s[s.length-1][1]+=n.substring(0,h),i.length1+=h,i.length2+=h}return n},e.prototype.patch_splitMax=function(t){for(var n=this.Match_MaxBits,r=0;r<t.length;r++)if(!(t[r].length1<=n)){var i=t[r];t.splice(r--,1);for(var s=i.start1,h=i.start2,a=\"\";0!==i.diffs.length;){var f=new e.patch_obj,l=!0;for(f.start1=s-a.length,f.start2=h-a.length,\"\"!==a&&(f.length1=f.length2=a.length,f.diffs.push([0,a]));0!==i.diffs.length&&f.length1<n-this.Patch_Margin;){var g=i.diffs[0][0],o=i.diffs[0][1];1===g?(f.length2+=o.length,h+=o.length,f.diffs.push(i.diffs.shift()),l=!1):-1===g&&1==f.diffs.length&&0==f.diffs[0][0]&&o.length>2*n?(f.length1+=o.length,s+=o.length,l=!1,f.diffs.push([g,o]),i.diffs.shift()):(o=o.substring(0,n-f.length1-this.Patch_Margin),f.length1+=o.length,s+=o.length,0===g?(f.length2+=o.length,h+=o.length):l=!1,f.diffs.push([g,o]),o==i.diffs[0][1]?i.diffs.shift():i.diffs[0][1]=i.diffs[0][1].substring(o.length))}a=(a=this.diff_text2(f.diffs)).substring(a.length-this.Patch_Margin);var c=this.diff_text1(i.diffs).substring(0,this.Patch_Margin);\"\"!==c&&(f.length1+=c.length,f.length2+=c.length,0!==f.diffs.length&&0===f.diffs[f.diffs.length-1][0]?f.diffs[f.diffs.length-1][1]+=c:f.diffs.push([0,c])),l||t.splice(++r,0,f)}}},e.prototype.patch_toText=function(t){for(var e=[],n=0;n<t.length;n++)e[n]=t[n];return e.join(\"\")},e.prototype.patch_fromText=function(t){var n=[];if(!t)return n;for(var r=t.split(\"\\n\"),i=0,s=/^@@ -(\\d+),?(\\d*) \\+(\\d+),?(\\d*) @@$/;i<r.length;){var h=r[i].match(s);if(!h)throw new Error(\"Invalid patch string: \"+r[i]);var a=new e.patch_obj;for(n.push(a),a.start1=parseInt(h[1],10),\"\"===h[2]?(a.start1--,a.length1=1):\"0\"==h[2]?a.length1=0:(a.start1--,a.length1=parseInt(h[2],10)),a.start2=parseInt(h[3],10),\"\"===h[4]?(a.start2--,a.length2=1):\"0\"==h[4]?a.length2=0:(a.start2--,a.length2=parseInt(h[4],10)),i++;i<r.length;){var f=r[i].charAt(0);try{var l=decodeURI(r[i].substring(1))}catch(t){throw new Error(\"Illegal escape in patch_fromText: \"+l)}if(\"-\"==f)a.diffs.push([-1,l]);else if(\"+\"==f)a.diffs.push([1,l]);else if(\" \"==f)a.diffs.push([0,l]);else{if(\"@\"==f)break;if(\"\"!==f)throw new Error('Invalid patch mode \"'+f+'\" in: '+l)}i++}}return n},e.patch_obj=function(){this.diffs=[],this.start1=null,this.start2=null,this.length1=0,this.length2=0},e.patch_obj.prototype.toString=function(){for(var t,e=[\"@@ -\"+(0===this.length1?this.start1+\",0\":1==this.length1?this.start1+1:this.start1+1+\",\"+this.length1)+\" +\"+(0===this.length2?this.start2+\",0\":1==this.length2?this.start2+1:this.start2+1+\",\"+this.length2)+\" @@\\n\"],n=0;n<this.diffs.length;n++){switch(this.diffs[n][0]){case 1:t=\"+\";break;case-1:t=\"-\";break;case 0:t=\" \"}e[n+1]=t+encodeURI(this.diffs[n][1])+\"\\n\"}return e.join(\"\").replace(/%20/g,\" \")},t.exports=e,t.exports.diff_match_patch=e,t.exports.DIFF_DELETE=-1,t.exports.DIFF_INSERT=1,t.exports.DIFF_EQUAL=0}))}();

const instance = new rollup();

const options = {
    cleanup: 'semantic',
    include: ['diffs', 'distance', 'html', 'patches', 'gnu_patch']
};
if (options_json) {
    try {
        Object.assign(options, JSON.parse(options.json));
        Object.assign(instance, options);
    }
    catch (err) {
        return null;
    }
}

const diffs = instance.diff_main(text1, text2, options.checklines);

if (options.cleanup === 'semantic')
    instance.diff_cleanupSemantic(diffs);

if (options.cleanup === 'efficiency')
    instance.diff_cleanupEfficiency(diffs);

const patches = options.include.indexOf('patch') >= 0 || options.include.indexOf('gnu_patch') >= 0 ? instance.patch_make(diffs) : undefined;

return {
    diffs: options.include.indexOf('diffs') >= 0 ? JSON.stringify(diffs) : null,
    patches: options.include.indexOf('patches') >= 0 ? JSON.stringify(patches) : null,
    html: options.include.indexOf('html') >= 0 ? instance.diff_prettyHtml(diffs) : null,
    distance: options.include.indexOf('distance') >= 0 ? instance.diff_levenshtein(diffs) : null,
    gnu_patch: options.include.indexOf('gnu_patch') >= 0 ? instance.patch_toText(patches) : null
};
""";
