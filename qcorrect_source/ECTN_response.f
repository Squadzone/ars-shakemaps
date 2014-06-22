      subroutine ECTN_response(station,input,inst_corr_flag)
      use traceinfo
      implicit none
      integer                     :: nday(50), mark(50,2)
      integer                     :: dayofevent
      integer                     :: inst_corr_flag, i, i_strcmp 
      character (len=*)           :: station ,input
      character (len=4)           :: list(50)
      data list(1:34)/'MIQ','LDQ','OTT','MNT','MNQ','GNT','FHO','GAC',
     1                'LPQ','SBQ','VDQ','WBO','CKO','TRQ','GRQ','JAQ',
     2                'GSQ','EBN','GGN','LMN','KLN','HTQ','WEO','SUO',
     3                'EEO','DPQ','SZO','SWO','A11','A16','A21','A54',
     4                'A61','A64'/
      data nday(1:34)/6210,6210,6210,6210,4082,6210,6210,6210,6210,4386,
     1                6210,6210,6210,6210,6210,6210,6210,6210,6210,6210,
     2                6210,6210,5077,6210,4683,6210,6210,6210,6210,6210,
     3                6210,6210,6210,6210/
      data mark(1:34,1)/1,2,1,1,1,1,2,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
     1                  3,1,3,3,3,3,3,3,3,3,3/
      data mark(1:34,2)/1,2,1,1,2,1,2,5,2,3,2,2,2,2,2,2,2,2,2,2,2,2,3,
     1                  3,3,3,3,3,3,3,3,3,3,3/
      read(input(1:4),'(i4)')year
      read(input(6:8),'(i3)')doy
      if(year >= 1992)then
           inst_corr_flag=0
           return
      endif
      call date2dayfrom1975(year,doy,dayofevent)
      do i=1,34
           if(i_strcmp(station,trim(list(i))) > 0)then
                if(dayofevent < nday(i))then
                        inst_corr_flag=mark(i,1)
                else
                        inst_corr_flag=mark(i,2)
                endif
                return
           endif
      enddo
      inst_corr_flag=0
      return
      end
