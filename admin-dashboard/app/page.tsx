"use client"

import * as React from "react"
import { 
  Users, 
  CreditCard, 
  Activity, 
  Calendar,
  Plus,
  ArrowRight,
  ChevronRight,
  TrendingUp,
  Zap,
} from "lucide-react"

import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { DashboardHeader } from "@/components/dashboard-header"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { QuickBookingDialog } from "@/components/quick-booking-dialog"

// Mock Data
const stats = [
  {
    title: "Današnje Rezervacije",
    value: "24",
    description: "+4 od juče",
    icon: Calendar,
    color: "text-primary",
  },
  {
    title: "Današnji Prihod",
    value: "42,500 RSD",
    description: "+12% od proseka",
    icon: CreditCard,
    color: "text-primary",
  },
  {
    title: "Popunjenost Terena",
    value: "85%",
    description: "Vršno vreme: 17:00 - 22:00",
    icon: Activity,
    color: "text-primary",
  },
  {
    title: "Aktivni Igrači",
    value: "148",
    description: "Trenutno u centru: 16",
    icon: Users,
    color: "text-primary",
  },
]

const courts = ["Teren 1", "Teren 2", "Teren 3", "Teren 4"]
const timeSlots = Array.from({ length: 29 }, (_, i) => {
  const hour = Math.floor(i / 2) + 8
  const minutes = i % 2 === 0 ? "00" : "30"
  return `${hour < 10 ? "0" + hour : hour}:${minutes}`
})

const mockBookings = [
  { id: 1, court: "Teren 1", time: "09:00", player: "Marko Marković", status: "confirmed" },
  { id: 2, court: "Teren 1", time: "10:30", player: "Jovan Jovanović", status: "confirmed" },
  { id: 3, court: "Teren 2", time: "09:00", player: "Nikola Nikolić", status: "pending" },
  { id: 4, court: "Teren 3", time: "17:00", player: "Stefan Stević", status: "confirmed" },
  { id: 5, court: "Teren 4", time: "18:30", player: "Petar Petrović", status: "confirmed" },
]

export default function DashboardPage() {
  const [isBookingOpen, setIsBookingOpen] = React.useState(false)
  const [selectedSlot, setSelectedSlot] = React.useState<{ court: string; time: string } | null>(null)

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
          initialData={selectedSlot ? { court: selectedSlot.court, time: selectedSlot.time } : undefined}
        />
        
        <main className="flex-1 space-y-8 p-8 pt-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-extrabold tracking-tight text-slate-900 mb-1">Dobrodošli, Admin</h2>
              <p className="text-muted-foreground font-medium">Evo šta se dešava danas u <span className="text-primary font-bold">PadelSpace</span>-u.</p>
            </div>
            <div className="flex items-center gap-2">
              <QuickBookingDialog>
                <Button className="bg-primary hover:bg-primary/90 text-white font-bold rounded-xl shadow-[0_4px_14px_0_rgba(255,0,153,0.39)] px-6 py-6 transition-all hover:scale-105 active:scale-95">
                  <Plus className="mr-2 h-5 w-5" /> Nova Rezervacija
                </Button>
              </QuickBookingDialog>
            </div>
          </div>

          {/* Stats Section */}
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {stats.map((stat) => (
              <Card key={stat.title} className="border-none shadow-sm hover:shadow-md transition-all duration-300 group bg-white">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-xs font-bold text-muted-foreground uppercase tracking-wider">{stat.title}</CardTitle>
                  <div className={`p-2 rounded-lg bg-slate-50 group-hover:bg-primary/10 transition-colors`}>
                    <stat.icon className={`h-4 w-4 ${stat.color} group-hover:scale-110 transition-transform`} />
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-black text-slate-900">{stat.value}</div>
                  <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1 font-medium">
                    <TrendingUp className="h-3 w-3 text-primary" /> <span className="text-primary font-bold">{stat.description.split(' ')[0]}</span> {stat.description.split(' ').slice(1).join(' ')}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="grid gap-6 md:grid-cols-7">
            {/* Today's Schedule */}
            <Card className="md:col-span-5 border-none shadow-sm bg-white overflow-hidden">
              <CardHeader className="flex flex-row items-center justify-between border-b border-slate-50 pb-4">
                <div>
                  <CardTitle className="text-xl font-bold text-slate-900">Današnji Raspored</CardTitle>
                  <CardDescription className="font-medium">Pregled svih terena po satnici</CardDescription>
                </div>
                <Button variant="ghost" size="sm" className="text-primary font-bold hover:text-primary hover:bg-primary/5">
                  Vidi sve <ChevronRight className="ml-1 h-4 w-4" />
                </Button>
              </CardHeader>
              <CardContent className="p-0">
                <ScrollArea className="h-[500px]">
                  <div className="min-w-[700px]">
                    <div className="grid grid-cols-[100px_repeat(4,1fr)] border-b border-slate-100 sticky top-0 bg-white/80 backdrop-blur-sm z-10">
                      <div className="p-4 text-xs font-black text-slate-400 uppercase tracking-widest">Vreme</div>
                      {courts.map((court) => (
                        <div key={court} className="p-4 text-xs font-black text-center text-slate-600 uppercase tracking-widest border-l border-slate-50">
                          {court}
                        </div>
                      ))}
                    </div>
                    {timeSlots.map((time) => (
                      <div key={time} className="grid grid-cols-[100px_repeat(4,1fr)] border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
                        <div className="p-4 text-sm font-bold text-slate-400">{time}</div>
                        {courts.map((court) => {
                          const booking = mockBookings.find(b => b.court === court && b.time === time);
                          return (
                            <div key={`${court}-${time}`} className="p-2 border-l border-slate-50 flex items-center justify-center min-h-[80px]">
                              {booking ? (
                                <div className={`w-full h-full p-3 rounded-xl flex flex-col justify-between shadow-sm transition-transform hover:scale-[1.02] cursor-pointer ${
                                  booking.status === 'confirmed' 
                                    ? 'bg-primary text-white shadow-[0_4px_12px_rgba(255,0,153,0.2)]' 
                                    : 'bg-slate-200 text-slate-600 shadow-sm'
                                }`}>
                                  <div className="text-[11px] font-black uppercase tracking-tight truncate leading-tight">{booking.player}</div>
                                  <div className="flex items-center justify-between mt-1">
                                    <span className="text-[9px] font-bold opacity-80 uppercase tracking-tighter">
                                      {booking.status === 'confirmed' ? 'Potvrđeno' : 'Na čekanju'}
                                    </span>
                                    <ArrowRight className="size-3 opacity-50" />
                                  </div>
        </div>
                              ) : (
                                <div className="w-full h-full flex items-center justify-center group/cell cursor-pointer">
                                  <div 
                                    onClick={() => handleQuickBooking(court, time)}
                                    className="size-10 rounded-2xl bg-slate-50 opacity-0 group-hover/cell:opacity-100 flex items-center justify-center hover:bg-primary hover:text-white transition-all duration-200"
                                  >
                                    <Plus className="size-5" />
                                  </div>
        </div>
                              )}
    </div>
  );
                        })}
                      </div>
                    ))}
                  </div>
                </ScrollArea>
              </CardContent>
            </Card>

            {/* Quick Actions & Recent Activity */}
            <div className="md:col-span-2 space-y-6">
              <Card className="border-none shadow-sm bg-white overflow-hidden group">
                <div className="absolute -top-6 -right-6 p-4 opacity-5 group-hover:opacity-10 transition-opacity">
                  <Zap className="size-32 text-primary fill-current" />
                </div>
                <CardHeader>
                  <CardTitle className="text-xl font-bold text-slate-900">Brze Akcije</CardTitle>
                </CardHeader>
                <CardContent className="grid gap-4">
                  <QuickBookingDialog>
                    <Button className="w-full justify-start rounded-xl bg-slate-900 hover:bg-primary text-white transition-all duration-300 px-4 py-6 group/btn">
                      <div className="size-8 rounded-lg bg-white/10 flex items-center justify-center mr-3 group-hover/btn:bg-white/20 transition-colors">
                        <Plus className="h-5 w-5 group-hover/btn:rotate-90 transition-transform" />
                      </div>
                      <span className="font-bold">Nova Rezervacija</span>
                    </Button>
                  </QuickBookingDialog>
                  <Button variant="outline" className="w-full justify-start rounded-xl border-slate-100 hover:border-primary hover:bg-primary/5 hover:text-primary transition-all duration-300 px-4 py-6">
                    <Users className="mr-3 h-5 w-5" />
                    <span className="font-bold">Novi Korisnik</span>
                  </Button>
                  <Button variant="outline" className="w-full justify-start rounded-xl border-slate-100 hover:border-primary hover:bg-primary/5 hover:text-primary transition-all duration-300 px-4 py-6">
                    <Activity className="mr-3 h-5 w-5" />
                    <span className="font-bold">Blokiraj Teren</span>
                  </Button>
                  
                  <div className="pt-2">
                    <Button variant="link" className="w-full text-primary font-bold hover:no-underline flex items-center justify-center gap-2 group">
                      Pregledaj sve rezervacije 
                      <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                    </Button>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-none shadow-sm bg-white overflow-hidden">
                <CardHeader className="border-b border-slate-50">
                  <CardTitle className="text-xs font-black uppercase tracking-widest text-slate-400">Nedavne Aktivnosti</CardTitle>
                </CardHeader>
                <CardContent className="p-0">
                  <div>
                    {[
                      { user: "Milan Perić", action: "napravio rezervaciju", time: "pre 5 min", type: "booking" },
                      { user: "Ana Lukić", action: "otkazala termin", time: "pre 15 min", type: "cancel" },
                      { user: "Marko Jurić", action: "se registrovao", time: "pre 1h", type: "user" },
                    ].map((activity, i) => (
                      <div key={i} className="flex items-center gap-4 p-4 hover:bg-slate-50 transition-colors border-b border-slate-50 last:border-0">
                        <div className={`size-3 rounded-full shadow-[0_0_8px_rgba(0,0,0,0.1)] ${
                          activity.type === 'booking' ? 'bg-primary' : activity.type === 'cancel' ? 'bg-red-500' : 'bg-slate-400'
                        }`} />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-bold text-slate-700 leading-tight">
                            <span className="text-slate-900">{activity.user}</span> 
                            <span className="text-slate-500 font-medium"> {activity.action}</span>
                          </p>
                          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-tighter mt-0.5">{activity.time}</p>
                        </div>
                        <ChevronRight className="size-4 text-slate-300" />
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </main>
      </SidebarInset>
    </SidebarProvider>
  )
}
