--  GHDL Run Time (GRT) - variable strings.
--  Copyright (C) 2002 - 2014 Tristan Gingold
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <gnu.org/licenses>.
--
--  As a special exception, if other files instantiate generics from this
--  unit, or you link this unit with other files to produce an executable,
--  this unit does not by itself cause the resulting executable to be
--  covered by the GNU General Public License. This exception does not
--  however invalidate any other reasons why the executable file might be
--  covered by the GNU Public License.

with Grt.C; use Grt.C;

package body Grt.Vstrings is
   procedure Free (Vstr : in out Vstring) is
   begin
      Free (To_Address (Vstr.Str));
      Vstr := (Str => null,
               Max => 0,
               Len => 0);
   end Free;

   procedure Reset (Vstr : in out Vstring) is
   begin
      Vstr.Len := 0;
   end Reset;

   procedure Grow (Vstr : in out Vstring; Sum : Natural)
   is
      Nlen : constant Natural := Vstr.Len + Sum;
      Nmax : Natural;
   begin
      Vstr.Len := Nlen;
      if Nlen <= Vstr.Max then
         return;
      end if;
      if Vstr.Max = 0 then
         Nmax := 32;
      else
         Nmax := Vstr.Max;
      end if;
      while Nmax < Nlen loop
         Nmax := Nmax * 2;
      end loop;
      Vstr.Str := To_Ghdl_C_String
        (Realloc (To_Address (Vstr.Str), size_t (Nmax)));
      if Vstr.Str = null then
         --  Memory exhausted.
         raise Storage_Error;
      end if;
      Vstr.Max := Nmax;
   end Grow;

   procedure Append (Vstr : in out Vstring; C : Character)
   is
   begin
      Grow (Vstr, 1);
      Vstr.Str (Vstr.Len) := C;
   end Append;

   procedure Append (Vstr : in out Vstring; Str : String)
   is
      S : constant Natural := Vstr.Len;
   begin
      Grow (Vstr, Str'Length);
      Vstr.Str (S + 1 .. S + Str'Length) := Str;
   end Append;

   procedure Append (Vstr : in out Vstring; Str : Ghdl_C_String)
   is
      S : constant Natural := Vstr.Len;
      L : constant Natural := strlen (Str);
   begin
      Grow (Vstr, L);
      Vstr.Str (S + 1 .. S + L) := Str (1 .. L);
   end Append;

   function Length (Vstr : Vstring) return Natural is
   begin
      return Vstr.Len;
   end Length;

   procedure Truncate (Vstr : in out Vstring; Len : Natural) is
   begin
      if Len > Vstr.Len then
         --  Incorrect length.
         raise Constraint_Error;
      end if;
      Vstr.Len := Len;
   end Truncate;

   function Get_Address (Vstr : Vstring) return Address is
   begin
      return To_Address (Vstr.Str);
   end Get_Address;

   function Get_C_String (Vstr : Vstring) return Ghdl_C_String is
   begin
      return Vstr.Str;
   end Get_C_String;
end Grt.Vstrings;
