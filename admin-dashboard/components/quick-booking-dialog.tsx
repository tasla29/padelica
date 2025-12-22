"use client"

import * as React from "react"
import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { format } from "date-fns"
import { srLatn } from "date-fns/locale"
import { CalendarIcon, Check, Loader2, Plus, Users } from "lucide-react"

import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Calendar } from "@/components/ui/calendar"
import { toast } from "sonner"

const bookingFormSchema = z.object({
  court: z.string().min(1, "Molimo izaberite teren."),
  date: z.date(),
  time: z.string().min(1, "Molimo izaberite vreme."),
  duration: z.string().min(1).default("90"),
  playerName: z.string().min(2, "Ime igrača mora imati bar 2 karaktera."),
  phone: z.string().optional(),
})

type BookingFormValues = z.infer<typeof bookingFormSchema>

const courts = [
  { id: "c1", name: "Teren 1" },
  { id: "c2", name: "Teren 2" },
  { id: "c3", name: "Teren 3" },
  { id: "c4", name: "Teren 4" },
]

const timeSlots = Array.from({ length: 29 }, (_, i) => {
  const hour = Math.floor(i / 2) + 8
  const minutes = i % 2 === 0 ? "00" : "30"
  return `${hour < 10 ? "0" + hour : hour}:${minutes}`
})

interface QuickBookingDialogProps {
  children?: React.ReactNode
  open?: boolean
  onOpenChange?: (open: boolean) => void
  initialData?: Partial<BookingFormValues>
}

export function QuickBookingDialog({ 
  children, 
  open, 
  onOpenChange,
  initialData 
}: QuickBookingDialogProps) {
  const [isSubmitting, setIsSubmitting] = React.useState(false)

  const form = useForm<BookingFormValues>({
    resolver: zodResolver(bookingFormSchema),
    defaultValues: {
      date: initialData?.date || new Date(),
      duration: initialData?.duration || "90",
      court: initialData?.court || "",
      time: initialData?.time || "",
      playerName: initialData?.playerName || "",
      phone: initialData?.phone || "",
    },
  })

  // Update form values when initialData changes or dialog opens
  React.useEffect(() => {
    if (open || !children) {
      form.reset({
        date: initialData?.date || new Date(),
        duration: initialData?.duration || "90",
        court: initialData?.court || "",
        time: initialData?.time || "",
        playerName: initialData?.playerName || "",
        phone: initialData?.phone || "",
      })
    }
  }, [initialData, open, form, children])

  const onSubmit = async (values: BookingFormValues) => {
    setIsSubmitting(true)
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000))
      console.log("Booking data:", values)
      toast("Rezervacija uspešno kreirana!", {
        description: `${values.playerName} - ${values.court} u ${values.time}`,
        icon: <Check className="h-4 w-4 text-primary" />,
      })
      onOpenChange?.(false)
      form.reset()
    } catch (error) {
      toast.error("Greška pri kreiranju rezervacije.")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      {children && <DialogTrigger asChild>{children}</DialogTrigger>}
      <DialogContent className="sm:max-w-[500px] bg-white border-none shadow-2xl rounded-3xl p-0 overflow-hidden">
        <div className="bg-slate-50 p-6 border-b border-slate-100">
          <DialogHeader>
            <DialogTitle className="text-2xl font-black flex items-center gap-2 text-slate-900">
              <Plus className="size-6 text-primary" /> Nova Rezervacija
            </DialogTitle>
            <DialogDescription className="text-slate-500 font-medium">
              Brzo kreirajte termin za igrača.
            </DialogDescription>
          </DialogHeader>
        </div>
        
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit as any)} className="p-6 space-y-6">
            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control as any}
                name="court"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-slate-900 font-bold">Teren</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="border-slate-100 rounded-xl focus:ring-primary">
                          <SelectValue placeholder="Izaberite teren" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent position="popper" className="bg-white border-slate-100 rounded-xl">
                        {courts.map((court) => (
                          <SelectItem key={court.id} value={court.name} className="focus:bg-primary focus:text-white">
                            {court.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control as any}
                name="duration"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-slate-900 font-bold">Trajanje</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="border-slate-100 rounded-xl focus:ring-primary">
                          <SelectValue placeholder="Trajanje" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent position="popper" className="bg-white border-slate-100 rounded-xl">
                        <SelectItem value="60" className="focus:bg-primary focus:text-white text-slate-700">60 min</SelectItem>
                        <SelectItem value="90" className="focus:bg-primary focus:text-white text-slate-700">90 min</SelectItem>
                        <SelectItem value="120" className="focus:bg-primary focus:text-white text-slate-700">120 min</SelectItem>
                      </SelectContent>
                    </Select>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control as any}
                name="date"
                render={({ field }) => (
                  <FormItem className="flex flex-col">
                    <FormLabel className="text-slate-900 font-bold">Datum</FormLabel>
                    <Popover>
                      <PopoverTrigger asChild>
                        <FormControl>
                          <Button
                            variant={"outline"}
                            className={cn(
                              "w-full pl-3 text-left font-medium border-slate-100 rounded-xl hover:bg-slate-50",
                              !field.value && "text-muted-foreground"
                            )}
                          >
                            {field.value ? (
                              format(field.value as Date, "PPP", { locale: srLatn })
                            ) : (
                              <span>Izaberite datum</span>
                            )}
                            <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                          </Button>
                        </FormControl>
                      </PopoverTrigger>
                      <PopoverContent className="w-auto p-0 bg-white border-slate-100 rounded-2xl shadow-xl" align="start">
                        <Calendar
                          mode="single"
                          selected={field.value as Date}
                          onSelect={field.onChange}
                          disabled={(date) =>
                            date < new Date(new Date().setHours(0, 0, 0, 0))
                          }
                          initialFocus
                          className="p-3"
                        />
                      </PopoverContent>
                    </Popover>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control as any}
                name="time"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-slate-900 font-bold">Vreme</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="border-slate-100 rounded-xl focus:ring-primary">
                          <SelectValue placeholder="Izaberite vreme" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent position="popper" className="bg-white border-slate-100 rounded-xl max-h-[200px] overflow-y-auto">
                        {timeSlots.map((time) => (
                          <SelectItem key={time} value={time} className="focus:bg-primary focus:text-white text-slate-700">
                            {time}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />
            </div>

            <div className="space-y-4 pt-4 border-t border-slate-50">
              <FormField
                control={form.control as any}
                name="playerName"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-slate-900 font-bold">Ime igrača</FormLabel>
                    <FormControl>
                      <div className="relative">
                        <Users className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                        <Input 
                          placeholder="npr. Marko Marković" 
                          className="pl-9 border-slate-100 rounded-xl focus:ring-primary" 
                          {...field} 
                        />
                      </div>
                    </FormControl>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control as any}
                name="phone"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-slate-900 font-bold">Telefon</FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="npr. +381 60 1234567" 
                        className="border-slate-100 rounded-xl focus:ring-primary" 
                        {...field} 
                      />
                    </FormControl>
                    <FormMessage className="text-[10px] font-bold" />
                  </FormItem>
                )}
              />
            </div>

            <DialogFooter className="pt-4">
              <Button 
                type="submit" 
                disabled={isSubmitting}
                className="w-full bg-primary hover:bg-primary/90 text-white font-black rounded-xl py-6 shadow-[0_4px_14px_0_rgba(255,0,153,0.39)] transition-all hover:scale-[1.02] active:scale-95"
              >
                {isSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Kreiranje...
                  </>
                ) : (
                  "Kreiraj Rezervaciju"
                )}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  )
}
