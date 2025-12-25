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
} from "lucide-react"

import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { DashboardHeader } from "@/components/dashboard-header"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { QuickBookingDialog } from "@/components/quick-booking-dialog"
import { ScheduleGrid } from "@/components/schedule-grid"

// Mock Data
const stats = [
  {
    title: "Današnje Rezervacije",
    value: "24",
    description: "+4 od juče",
    icon: Calendar,
  },
  {
    title: "Današnji Prihod",
    value: "42,500 RSD",
    description: "+12% od proseka",
    icon: CreditCard,
  },
  {
    title: "Popunjenost Terena",
    value: "85%",
    description: "Vršno vreme: 17:00 - 22:00",
    icon: Activity,
  },
  {
    title: "Aktivni Igrači",
    value: "148",
    description: "Trenutno u centru: 16",
    icon: Users,
  },
]

const mockBookings = [
  { id: 1, court: "Teren 1", time: "09:00", duration: 60, player: "Marko Marković", status: "confirmed" },
  { id: 2, court: "Teren 1", time: "10:30", duration: 90, player: "Jovan Jovanović", status: "confirmed" },
  { id: 3, court: "Teren 2", time: "09:00", duration: 120, player: "Nikola Nikolić", status: "pending" },
  { id: 4, court: "Teren 3", time: "17:00", duration: 60, player: "Stefan Stević", status: "confirmed" },
  { id: 5, court: "Teren 4", time: "18:30", duration: 90, player: "Petar Petrović", status: "confirmed" },
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
        
        <div className="flex-1 min-w-0 space-y-6 p-8 pt-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold tracking-tight text-slate-900">Kontrolna tabla</h2>
              <p className="text-sm text-muted-foreground">Pregled današnjih aktivnosti</p>
            </div>
            <div className="flex items-center gap-2">
              <QuickBookingDialog>
                <Button className="bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg shadow-sm px-4">
                  <Plus className="mr-2 h-4 w-4" /> Nova Rezervacija
                </Button>
              </QuickBookingDialog>
            </div>
          </div>

          {/* Stats Section */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            {stats.map((stat) => (
              <Card key={stat.title} className="border border-slate-200 shadow-sm bg-white rounded-xl">
                <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
                  <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{stat.title}</CardTitle>
                  <stat.icon className="h-4 w-4 text-slate-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-slate-900">{stat.value}</div>
                  <p className="text-[11px] text-muted-foreground mt-1 font-medium flex items-center gap-1">
                    <TrendingUp className="h-3 w-3 text-slate-400" /> {stat.description}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="grid gap-6 md:grid-cols-7">
            {/* Today's Schedule */}
            <div className="md:col-span-5 min-w-0">
              <ScheduleGrid 
                date={new Date()} 
                bookings={mockBookings as any} 
                onSlotClick={handleQuickBooking}
              />
            </div>

            {/* Quick Actions & Recent Activity */}
            <div className="md:col-span-2 space-y-6 min-w-0">
              <Card className="border border-slate-200 shadow-sm bg-white rounded-xl">
                <CardHeader>
                  <CardTitle className="text-lg font-bold text-slate-900">Brze Akcije</CardTitle>
                </CardHeader>
                <CardContent className="grid gap-2">
                  <QuickBookingDialog>
                    <Button variant="outline" className="w-full justify-start rounded-lg border-slate-200 hover:bg-slate-50 font-medium">
                      <Plus className="mr-3 h-4 w-4 text-slate-500" />
                      Nova Rezervacija
                    </Button>
                  </QuickBookingDialog>
                  <Button variant="outline" className="w-full justify-start rounded-lg border-slate-200 hover:bg-slate-50 font-medium">
                    <Users className="mr-3 h-4 w-4 text-slate-500" />
                    Novi Korisnik
                  </Button>
                  <Button variant="outline" className="w-full justify-start rounded-lg border-slate-200 hover:bg-slate-50 font-medium">
                    <Activity className="mr-3 h-4 w-4 text-slate-500" />
                    Blokiraj Teren
                  </Button>
                </CardContent>
              </Card>

              <Card className="border border-slate-200 shadow-sm bg-white rounded-xl overflow-hidden">
                <CardHeader className="border-b border-slate-100 bg-slate-50/50">
                  <CardTitle className="text-xs font-bold uppercase tracking-wider text-slate-500">Nedavne Aktivnosti</CardTitle>
                </CardHeader>
                <CardContent className="p-0">
                  <div className="divide-y divide-slate-100">
                    {[
                      { user: "Milan Perić", action: "napravio rezervaciju", time: "pre 5 min", type: "booking" },
                      { user: "Ana Lukić", action: "otkazala termin", time: "pre 15 min", type: "cancel" },
                      { user: "Marko Jurić", action: "se registrovao", time: "pre 1h", type: "user" },
                    ].map((activity, i) => (
                      <div key={i} className="flex items-center gap-3 p-4 hover:bg-slate-50 transition-colors">
                        <div className={`size-2 rounded-full ${
                          activity.type === 'booking' ? 'bg-primary' : activity.type === 'cancel' ? 'bg-rose-500' : 'bg-slate-400'
                        }`} />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-semibold text-slate-700 leading-tight">
                            {activity.user} <span className="text-slate-500 font-normal">{activity.action}</span>
                          </p>
                          <p className="text-[10px] font-medium text-slate-400 mt-0.5">{activity.time}</p>
                        </div>
                        <ChevronRight className="size-4 text-slate-300" />
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
