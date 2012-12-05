/**********************************************************************
%   Copyright 2012 Analog Devices, Inc.
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
**********************************************************************/


/* Given some text, make it into only lowercase a-z and space.  Also,
   compress consecutive white space into a single character. */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

main(){

  int ch,prev_space;
  
  prev_space=0;
  while (EOF!=(ch=fgetc(stdin))){
    if (isalpha(ch)){
      prev_space=0;
      ch=tolower(ch);
      printf("%c",ch);
    }
    else if (isspace(ch)){
      if (prev_space==0) {
	  printf(" ");
	}
      prev_space=1;
    }
  }
}

  
