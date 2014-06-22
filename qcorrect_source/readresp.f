      subroutine readresp(fname,iflag)
      use respinfo
      implicit none
      integer                :: stage1=0, stageL=0, nstage, n_curr_stage
      integer                :: ZeroCount=0, PoleCount=0, i_strcmp
      integer                :: is=0, nline=0, iacc, iflag, i, j
      real                   :: G=1., z1, z2, p1, p2
      complex                :: accresp, velresp, dspresp
      character (len=*)      :: fname
      character (len=80)     :: respread(10000)=''
c     integer                :: stage1=0, stageL=0, nstage, n_curr_stage
c     integer                :: ZeroCount=0, PoleCount=0, i_strcmp
c     integer                :: is=0, nline=0, iflag, i, j
c     real                   :: G=1., z1, z2, p1, p2
c     complex                :: accresp, velresp, dspresp
c     character (len=*)      :: fname
c     character (len=80)     :: respread(10000)=''

      stage1=0
      stageL=0
      ZeroCount=0
      PoleCount=0
      is=0
      nline=0
      G=1.
      respread=''
      iacc=0
      if(iflag.eq.0)then
           open(unit=4,file=fname,status='unknown')
           do while (is==0)
                nline=nline+1
                read(4,'(a80)',iostat=is)respread(nline)
           enddo
           close(unit=4)
           do i=1,nline,1
                if(i_strcmp(respread(i),'Stage number:')>0.or.
     1             i_strcmp(respread(i),'Stage sequence')>0)then
                     read(respread(i)(52:),'(i6)')n_curr_stage
                endif
                if(n_curr_stage==1)stage1=1
                if(n_curr_stage/=1)stage1=0
                if(n_curr_stage==0)stageL=1
                if(n_curr_stage/=0)stageL=0
                if(stage1==1.and.i_strcmp(respread(i),'M/S**2')>0)then
                     iacc=1
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'A0 normalization factor:')>0)then
                     read(respread(i)(52:),*)A0
                endif
                if(stage1==1.and.i_strcmp(respread(i),'Gain:')>0)then
                     read(respread(i)(52:),*)G
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'Normalization frequency:')>0)then
                     read(respread(i)(52:),*)f0
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'Number of zeroes:')>0)then
                     read(respread(i)(52:),*)nzero
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'Number of poles:')>0)then
                     read(respread(i)(52:),*)npole
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'Complex zeroes:')>0)then
                     do j=i+2,i+nzero+1
                     ZeroCount=ZeroCount+1
                     read(respread(j)(17:),*)z1,z2
                     z(ZeroCount)=cmplx(z1,z2)
                     enddo
                     if(iacc==1)then
                          ZeroCount=ZeroCount+1
                          z(ZeroCount)=cmplx(0.,0.)
                     endif
                     nzero=ZeroCount
                endif
                if(stage1==1.and.
     1          i_strcmp(respread(i),'Complex poles:')>0)then
                     do j=i+2,i+npole+1
                     PoleCount=PoleCount+1
                     read(respread(j)(17:),*)p1,p2
                     p(PoleCount)=cmplx(p1,p2)
                     enddo
                endif
                if(stageL==1.and.
     1          i_strcmp(respread(i),'Sensitivity:')>0)then
                     read(respread(i)(52:),*)sensitivity
                endif 
           enddo
      elseif(iflag.eq.1)then
           call mark1()
      elseif(iflag.eq.2)then
           call mark2()
      elseif(iflag.eq.3)then
           call mark3()
      elseif(iflag.eq.5)then
           call mark5()
      endif
      call response(real(f0),accresp, velresp, dspresp)
      if(abs(cabs(velresp/real(sensitivity))-1.) > 0.0001)A0ok=0.

      return
      end
