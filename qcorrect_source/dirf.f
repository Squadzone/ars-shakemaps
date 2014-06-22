c     Subroutine dirf is playing the role of dirf in SEISAN, but instead
c     it has more desired features. It accepts two arguments: 1) wcard
c     which is a string of the form of part of file name and 2) filename
c     which is the name of output file for extracted list. The dirf sub-
c     routine writes outputs in output file starting at column 1.
c
      subroutine dirf(wcard,filename)
      implicit none
      character (len=*)           :: wcard, filename
      character (len=1000)        :: command
      command='ls *'//trim(wcard)//'* > '//trim(filename)
      call system(trim(command))
      return
      end
