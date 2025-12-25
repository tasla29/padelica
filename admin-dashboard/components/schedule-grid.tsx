"use client"

import * as React from "react"
import { Plus } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"

interface Booking {
  id: number | string
  court: string
  time: string
  duration: number
  player: string
  status: string
}

interface ScheduleGridProps {
  date: Date
  bookings: Booking[]
  onSlotClick?: (court: string, time: string) => void
  showTitle?: boolean
}

const courts = ["Teren 1", "Teren 2", "Teren 3", "Teren 4"]
const timeSlots = Array.from({ length: 29 }, (_, i) => {
  const hour = Math.floor(i / 2) + 8
  const minutes = i % 2 === 0 ? "00" : "30"
  return `${hour < 10 ? "0" + hour : hour}:${minutes}`
})

export function ScheduleGrid({ date, bookings, onSlotClick, showTitle = true }: ScheduleGridProps) {
  return (
    <Card className="border border-slate-200 shadow-sm bg-white overflow-hidden rounded-xl">
      {showTitle && (
        <CardHeader className="flex flex-row items-center justify-between border-b border-slate-100 pb-4 bg-slate-50/50">
          <div>
            <CardTitle className="text-lg font-bold text-slate-900">Raspored</CardTitle>
            <CardDescription className="text-sm">Pregled svih terena po satnici</CardDescription>
          </div>
        </CardHeader>
      )}
      <CardContent className="p-0">
        <div className="relative">
          <div className="overflow-x-auto w-full custom-scrollbar">
            <div className="w-max">
              <div className="grid grid-cols-[120px_repeat(29,60px)] border-b border-slate-200 sticky top-0 bg-white z-30">
                <div className="p-4 text-[10px] font-bold text-slate-500 uppercase tracking-wider sticky left-0 bg-white border-r border-slate-200 z-40">Tereni</div>
                {timeSlots.map((time) => (
                  <div key={time} className="p-4 text-[10px] font-semibold text-center text-slate-400 border-l border-slate-100 w-[60px]">
                    {time}
                  </div>
                ))}
              </div>
              {courts.map((court) => {
                const courtBookings = bookings.filter(b => b.court === court);
                const renderedSlots: React.ReactNode[] = [];
                let skipUntil: number = -1;

                timeSlots.forEach((time, index) => {
                  if (index <= skipUntil) return;

                  const booking = courtBookings.find(b => b.time === time);
                  if (booking) {
                    const span = booking.duration / 30;
                    skipUntil = index + span - 1;
                    renderedSlots.push(
                      <div 
                        key={`${court}-${time}`} 
                        className="p-1 border-l border-slate-100 flex items-center justify-center min-h-[80px]"
                        style={{ gridColumn: `span ${span}` }}
                      >
                        <div className={`w-full h-full p-2 rounded-lg flex flex-col justify-center border transition-all ${
                          booking.status === 'confirmed' || booking.status === 'completed'
                            ? 'bg-slate-900 text-white border-slate-900 shadow-sm' 
                            : 'bg-slate-100 text-slate-600 border-slate-200 shadow-sm'
                        }`}>
                          <div className="text-[10px] font-bold truncate leading-tight">{booking.player}</div>
                          <div className="text-[9px] font-medium opacity-80 mt-1">
                            {booking.status === 'confirmed' || booking.status === 'completed' ? 'Potv.' : 'Ček.'} • {booking.duration}m
                          </div>
                        </div>
                      </div>
                    );
                  } else {
                    renderedSlots.push(
                      <div key={`${court}-${time}`} className="p-1 border-l border-slate-100 flex items-center justify-center min-h-[80px] w-[60px]">
                        <div className="w-full h-full flex items-center justify-center group/cell cursor-pointer">
                          <div 
                            onClick={() => onSlotClick?.(court, time)}
                            className="size-8 rounded-lg bg-slate-50 opacity-0 group-hover/cell:opacity-100 flex items-center justify-center hover:bg-slate-100 hover:text-slate-900 border border-transparent hover:border-slate-200 transition-all duration-200"
                          >
                            <Plus className="size-4" />
                          </div>
                        </div>
                      </div>
                    );
                  }
                });

                return (
                  <div key={court} className="grid grid-cols-[120px_repeat(29,60px)] border-b border-slate-100 hover:bg-slate-50/50 transition-colors">
                    <div className="p-4 text-sm font-semibold text-slate-600 sticky left-0 bg-white border-r border-slate-200 z-20 shadow-[1px_0_0_rgba(0,0,0,0.05)]">{court}</div>
                    {renderedSlots}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
