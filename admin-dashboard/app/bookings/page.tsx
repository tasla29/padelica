"use client"

import * as React from "react"
import { CalendarIcon, Plus } from "lucide-react"
import { format } from "date-fns"
import { srLatn } from "date-fns/locale"

import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { DashboardHeader } from "@/components/dashboard-header"
import { Button } from "@/components/ui/button"
import { QuickBookingDialog } from "@/components/quick-booking-dialog"
import { BookingsTable } from "@/components/bookings-table"
import { ScheduleGrid } from "@/components/schedule-grid"
import { Calendar } from "@/components/ui/calendar"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { cn } from "@/lib/utils"

// Mock bookings for different dates
const mockBookingsByDate: Record<string, any[]> = {
  "2024-12-24": [
    { id: 1, court: "Teren 1", time: "09:00", duration: 60, player: "Marko Marković", status: "confirmed" },
    { id: 2, court: "Teren 1", time: "10:30", duration: 90, player: "Jovan Jovanović", status: "confirmed" },
    { id: 3, court: "Teren 2", time: "09:00", duration: 120, player: "Nikola Nikolić", status: "pending" },
  ],
  "default": [
    { id: 4, court: "Teren 3", time: "17:00", duration: 60, player: "Stefan Stević", status: "confirmed" },
    { id: 5, court: "Teren 4", time: "18:30", duration: 90, player: "Petar Petrović", status: "confirmed" },
  ]
}

export default function BookingsPage() {
  const [date, setDate] = React.useState<Date>(new Date())
  const [isBookingOpen, setIsBookingOpen] = React.useState(false)
  const [selectedSlot, setSelectedSlot] = React.useState<{ court: string; time: string } | null>(null)

  const formattedDateKey = format(date, "yyyy-MM-dd")
  const currentBookings = mockBookingsByDate[formattedDateKey] || mockBookingsByDate["default"]

  const handleQuickBooking = (court: string, time: string) => {
    setSelectedSlot({ court, time })
    setIsBookingOpen(true)
  }

  return (
    <SidebarProvider className="bg-[#151c28]">
      <AppSidebar />
      <SidebarInset className="bg-background">
        <DashboardHeader />
        
        <QuickBookingDialog 
          open={isBookingOpen} 
          onOpenChange={setIsBookingOpen}
          initialData={selectedSlot ? { court: selectedSlot.court, time: selectedSlot.time, date } : { date }}
        />

        <div className="flex-1 min-w-0 space-y-6 p-8 pt-6">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <h2 className="text-2xl font-bold tracking-tight text-slate-900">Rezervacije</h2>
              <p className="text-sm text-muted-foreground">Upravljajte terminima i pregledajte raspored</p>
            </div>
            <div className="flex items-center gap-3">
              <Popover>
                <PopoverTrigger asChild>
                  <Button
                    variant={"outline"}
                    className={cn(
                      "w-[200px] justify-start text-left font-semibold rounded-lg border-slate-200 h-10 shadow-sm text-sm",
                      !date && "text-muted-foreground"
                    )}
                  >
                    <CalendarIcon className="mr-2 h-4 w-4 text-slate-400" />
                    {date ? format(date, "PPP", { locale: srLatn }) : <span>Izaberi datum</span>}
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-auto p-0 bg-white border-slate-200 rounded-xl shadow-lg" align="end">
                  <Calendar
                    mode="single"
                    selected={date}
                    onSelect={(d) => d && setDate(d)}
                    initialFocus
                    className="p-3"
                  />
                </PopoverContent>
              </Popover>

              <QuickBookingDialog>
                <Button className="bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg shadow-sm px-4 h-10 transition-all">
                  <Plus className="mr-2 h-4 w-4" /> Nova Rezervacija
                </Button>
              </QuickBookingDialog>
            </div>
          </div>

          {/* Visual Schedule View */}
          <div className="space-y-3 max-w-full overflow-hidden">
            <h3 className="text-sm font-bold text-slate-500 uppercase tracking-wider flex items-center gap-2">
              Vizuelni Pregled
            </h3>
            <ScheduleGrid 
              date={date} 
              bookings={currentBookings} 
              onSlotClick={handleQuickBooking}
              showTitle={false}
            />
          </div>

          {/* List View */}
          <div className="space-y-3 max-w-full overflow-hidden">
            <h3 className="text-sm font-bold text-slate-500 uppercase tracking-wider flex items-center gap-2">
              Lista Rezervacija
            </h3>
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
              <BookingsTable />
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
